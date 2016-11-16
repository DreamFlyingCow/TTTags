//
//  TTTagView.m
//  Tags
//
//  Created by 赵春浩 on 16/8/15.
//  Copyright © 2016年 Mr Zhao. All rights reserved.
//

#import "TTTagView.h"

@interface TTCheckBoxButton :UIButton
/**
 *  未被选中时标签的背景颜色
 */
@property (nonatomic, strong) UIColor *colorBg;
/**
 *  未被选中时标签的文字的颜色
 */
@property (nonatomic, strong) UIColor *colorText;
/**
 *  未被选中时标签的边框颜色
 */
@property (strong, nonatomic) UIColor *borderColor;
/**
 *  被选中时标签的背景颜色
 */
@property (nonatomic, strong) UIColor *selColorBg;
/**
 *  被选中时标签的文字的颜色
 */
@property (nonatomic, strong) UIColor *selColorText;
/**
 *  被选中时标签的边框颜色
 */
@property (strong, nonatomic) UIColor *selBorderColor;

@end


@implementation TTCheckBoxButton

- (void)setSelected:(BOOL)selected {
    
    [super setSelected:selected];
    if (selected) {
        
        [self setBackgroundColor:_selColorBg];
        self.layer.borderColor = _selBorderColor.CGColor;
        self.layer.borderWidth = 1;
        [self setTitleColor:_selColorText forState:UIControlStateSelected];
    } else {
        
        [self setBackgroundColor:_colorBg];
        self.layer.borderColor = _borderColor.CGColor;
        self.layer.borderWidth = 1;
        [self setTitleColor:_colorText forState:UIControlStateNormal];
    }
    [self setNeedsDisplay];
}

@end


@interface TTTextField : UITextField

@end

@implementation TTTextField

// 设置占位文本的位置
- (CGRect)textRectForBounds:(CGRect)bounds {
    
    return CGRectInset( bounds , 12.5 , 0 );
}

// 设置文本的位置
- (CGRect)editingRectForBounds:(CGRect)bounds {
    
    return CGRectInset( bounds , 12.5 , 0 );
}

@end


@interface TTTagView() <UITextFieldDelegate>

/**
 *  容器view
 */
@property (nonatomic, strong) UIScrollView *svContainer;
/**
 *  标签按钮的数组
 */
@property (nonatomic, strong) NSMutableArray *tagButtons;
/**
 *  用来记录标签上边的文本
 */
@property (nonatomic, strong) NSMutableArray *tagStrings;
/**
 *  标记被选中的标签
 */
@property (nonatomic, strong) NSMutableArray *tagStringsSelected;
/**
 *  点击inputView的手势 (用来取消被选中的标签, 还有结束编辑状态, 生成新的标签)
 */
@property (nonatomic) UITapGestureRecognizer *gestureRecognizer;
/**
 *  被选中的标签
 */
@property (strong, nonatomic) TTCheckBoxButton *selectedBtn;

@end

@interface TTTagView ()

// 当输入的文字过长时用来存储总长度的
@property (assign, nonatomic) CGFloat currentMaxLength;
// 判定是否是第一行还没有标签(防止在第一行编辑标签的时候就进行换行导致第一行空出来)
@property (assign, nonatomic) BOOL isFirst;

@end

@implementation TTTagView {
    
    // 正在编辑的标签的下标
    NSInteger _editingTagIndex;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

#pragma mark - 初始化一些控件
- (void)commonInit {
    
    /**
     *  默认的标签类型(编辑)
     */
    _type = TTTagView_Type_Edit;
    /**
     *  默认的标签宽度
     */
    _tagWidht = 85;
    /**
     *  默认的标签高度
     */
    _tagHeight = 30;
    /**
     *  第一个参数是左右两个标签之间的间隔  第二个参数是上下两个标签之间的间隔
     */
    _tagPaddingSize = CGSizeMake(10, 10);
    /**
     *  第一个参数表示标签内部text文本左右距离文本框的距离
     */
    _textPaddingSize = CGSizeMake(12.5, 0);
    /**
     *  标签字体大小
     */
    _fontTag = [UIFont systemFontOfSize:14];
    /**
     *  输入标签的字体大小
     */
    _fontInput = [UIFont systemFontOfSize:14];
    
    _inputBgColor = kColorRGB(0xffffff);
    _inputPlaceHolderTextColor = kColorRGB(0xcccccc);
    _inputTextColor = kColorRGB(0x000000);
    _inputBorderColor = kColorRGB(0xfafafa);
    _bgColor = kColorRGB(0xffffff);
    _textColor = kColorRGB(0xffae00);
    _borderColor = kColorRGB(0xffae00);
    _selBgColor = kColorRGB(0xffae00);
    _selTextColor = kColorRGB(0xffffff);
    _selBorderColor = kColorRGB(0xffae00);
    
    _viewMaxHeight = 130;
    self.backgroundColor = kColorRGB(0xffffff);
    
    self.currentMaxLength = 0;
    /**
     *  标签中的按钮
     */
    _tagButtons = [NSMutableArray new];
    /**
     *  标签上显示的文字
     */
    _tagStrings = [NSMutableArray new];
    /**
     *  被选中的标签
     */
    _tagStringsSelected = [NSMutableArray new];
    
    {
        
        /**
         *  标签所在的view(UIScrollView)
         */
        UIScrollView *sv = [[UIScrollView alloc] initWithFrame:self.bounds];
        sv.contentSize = sv.frame.size;
        self.changeHeight = sv.contentSize.height;
        sv.indicatorStyle = UIScrollViewIndicatorStyleDefault;
        sv.backgroundColor = self.backgroundColor;
        // 取消弹簧效果
        sv.bounces = NO;
        // 垂直滚动条
        sv.showsVerticalScrollIndicator = YES;
        // 水平滚动条
        sv.showsHorizontalScrollIndicator = NO;
        [self addSubview:sv];
        _svContainer = sv;
    }
    {
        // 默认的标签
        UITextField* tf = [[TTTextField alloc] initWithFrame:CGRectMake(0, 0, _tagWidht, _tagHeight)];
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        [tf addTarget:self action:@selector(textFieldDidFinishChange:)forControlEvents:UIControlEventEditingChanged];
        tf.delegate = self;
        tf.placeholder = @"添加标签";
        
        tf.returnKeyType = UIReturnKeyDone;
        [_svContainer addSubview:tf];
        _tfInput = tf;
    }
    {
        _gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        _gestureRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:_gestureRecognizer];
    }
}


- (NSMutableArray *)tagStrings {
    
      switch (_type) {
        case TTTagView_Type_Edit: {
            
            return _tagStrings;
        }
            break;

        case TTTagView_Type_Selected: {
            
            [_tagStringsSelected removeAllObjects];
            for (TTCheckBoxButton *button in _tagButtons) {
                if (button.selected) {
                    [_tagStringsSelected addObject:button.titleLabel.text];
                    break;
                }
            }
            return _tagStringsSelected;
        }
            break;
              
        default: {
            
        }
            break;
    }
    return nil;
}

#pragma mark - 对标签进行重新布局
- (void)layoutTagviews {
    
    self.isFirst = YES;
    if (self.selectedBtn != nil) {
        [self.selectedBtn setSelected:NO];
    }
    
    float oldContentHeight = _svContainer.contentSize.height;
    float offsetX = _tagPaddingSize.width,  offsetY = _tagPaddingSize.height;
    for (int i = 0; i < _tagButtons.count; i ++) {
        TTCheckBoxButton *tagButton = _tagButtons[i];
        CGRect frame = tagButton.frame;
        self.isFirst = NO;

            if ((offsetX + tagButton.frame.size.width + _tagPaddingSize.width) <= _svContainer.contentSize.width) {
                
                frame.origin.x = offsetX;
                frame.origin.y = offsetY;
                offsetX += tagButton.frame.size.width + _tagPaddingSize.width;
            }else if (i != 0) {
                
                offsetX = _tagPaddingSize.width;
                offsetY += _tagHeight + _tagPaddingSize.height;
                
                frame.origin.x = offsetX;
                frame.origin.y = offsetY;
                offsetX += tagButton.frame.size.width + _tagPaddingSize.width;
            } else {
                
                offsetX = _tagPaddingSize.width;
                frame.origin.x = offsetX;
                frame.origin.y = offsetY;
                offsetX += tagButton.frame.size.width + _tagPaddingSize.width;
                
            }

        tagButton.frame = frame;
    }
    
    _tfInput.hidden = (_type != TTTagView_Type_Edit);
    if (_type == TTTagView_Type_Edit) {
        
        _tfInput.font = _fontInput;
        
        _tfInput.backgroundColor = _inputBgColor;
        _tfInput.textColor = _inputTextColor;
        [_tfInput setValue:_inputPlaceHolderTextColor forKeyPath:@"_placeholderLabel.textColor"];
        _tfInput.layer.borderColor = _inputBorderColor.CGColor;
        
        _tfInput.layer.cornerRadius = _tfInput.frame.size.height * 0.5f;
        _tfInput.layer.borderWidth = 1;
        {
            CGRect frame = _tfInput.frame;
            frame.size.width = [_tfInput.text sizeWithAttributes:@{NSFontAttributeName:_fontInput}].width + _tfInput.layer.cornerRadius * 2.0f + _textPaddingSize.width * 2.0;
            frame.size.width = MAX(frame.size.width, _tagWidht);
            _tfInput.frame = frame;
        }
        CGRect frame = _tfInput.frame;

            if ((offsetX + _tfInput.frame.size.width + _tagPaddingSize.width) <= _svContainer.contentSize.width) {
                frame.origin.x = offsetX;
                frame.origin.y = offsetY;
            }else if (!self.isFirst) {
                
                offsetX = _tagPaddingSize.width;
                offsetY += _tagHeight + _tagPaddingSize.height;
                
                frame.origin.x = offsetX;
                frame.origin.y = offsetY;
            } else {
                
                offsetX = _tagPaddingSize.width;
                frame.origin.x = offsetX;
                frame.origin.y = offsetY;
            }
        _tfInput.frame = frame;
        
    }
    
    _svContainer.contentSize = CGSizeMake(_svContainer.contentSize.width, offsetY + _tagHeight + _tagPaddingSize.height);
    {
        CGRect frame = _svContainer.frame;
        frame.size.height = _svContainer.contentSize.height;
        frame.size.height = MIN(frame.size.height, _viewMaxHeight);
        _svContainer.frame = frame;
    }
    
    {
        CGRect frame = self.frame;
        frame.size.height = _svContainer.frame.size.height;
        self.frame = frame;
    }

    if (oldContentHeight != _svContainer.contentSize.height) {
        CGPoint bottomOffset = CGPointMake(0, _svContainer.contentSize.height - _svContainer.bounds.size.height);
        [_svContainer setContentOffset:bottomOffset animated:YES];
    }
    
    self.changeHeight = _svContainer.frame.size.height;
}

#pragma mark - 在textField上边添加一个按钮
- (TTCheckBoxButton *)tagButtonWithTag:(NSString *)tag {
    
    TTCheckBoxButton *tagBtn = [[TTCheckBoxButton alloc] init];
    
    tagBtn.colorText = _textColor;
    tagBtn.colorBg = _bgColor;
    tagBtn.borderColor = _borderColor;
    
    tagBtn.selColorBg = _selBgColor;
    tagBtn.selColorText = _selTextColor;
    tagBtn.selBorderColor = _selBorderColor;
    
    tagBtn.selected = NO;
    [tagBtn.titleLabel setFont:_fontTag];
    [tagBtn addTarget:self action:@selector(handlerTagButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [tagBtn setTitle:tag forState:UIControlStateSelected];
    [tagBtn setTitle:tag forState:UIControlStateNormal];
    CGRect btnFrame = CGRectMake(0, 0, 0, 0);
    btnFrame.size.height = _tagHeight;
    tagBtn.layer.cornerRadius = btnFrame.size.height * 0.5f;
    btnFrame.size.width = [tagBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_fontTag}].width + (tagBtn.layer.cornerRadius * 2.0f);
    
    tagBtn.frame = btnFrame;
    return tagBtn;
}

#pragma mark - 按钮的点击事件
- (void)handlerTagButtonEvent:(TTCheckBoxButton *)sender {
    
    [self textFieldShouldReturn:_tfInput];
    if (self.selectedBtn != nil) {
        [self.selectedBtn setSelected:NO];
    }

    self.selectedBtn = sender;
    [self.selectedBtn setSelected:YES];
    
}
#pragma mark action 添加标签

- (void)addTags:(NSArray *)tags {
    
    for (NSString *tag in tags) {
        [self addTagToLast:tag];
    }
    
    [self layoutTagviews];
    
}

- (void)addTags:(NSArray *)tags selectedTags:(NSArray*)selectedTags {
    
    [self addTags:tags];
    self.tagStringsSelected = [NSMutableArray arrayWithArray:selectedTags];
}

- (void)addTagToLast:(NSString *)tag {
    
    NSArray *result = [_tagStrings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == %@", tag]];
    if (result.count == 0) {
        [_tagStrings addObject:tag];
        [_svContainer scrollRectToVisible:CGRectMake(_svContainer.left, _svContainer.contentSize.height - 50, kScreenWidth, 50) animated:YES];
        if ([self.delegate respondsToSelector:@selector(finishInput:)]) {
            [self.delegate finishInput:tag];
        }
        
        TTCheckBoxButton *tagButton = [self tagButtonWithTag:tag];
        [tagButton addTarget:self action:@selector(handlerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_svContainer addSubview:tagButton];
        [_tagButtons addObject:tagButton];
        
        switch (_type) {
            case TTTagView_Type_Selected: {
                tagButton.selected = NO;
            }
                break;
            default:
                break;
        }
    }
    [self layoutTagviews];
}

#pragma mark - 删除标签
- (void)removeTags:(NSArray *)tags {
    
    for (NSString *tag in tags) {
        [self removeTag:tag];
    }
    [self layoutTagviews];
}

- (void)removeTag:(NSString *)tag {
    
    NSArray *result = [_tagStrings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == %@", tag]];
    if (result) {
        
        NSInteger index = [_tagStrings indexOfObject:tag];
        [_tagStrings removeObjectAtIndex:index];
        [_tagButtons[index] removeFromSuperview];
        [_tagButtons removeObjectAtIndex:index];
        
        [_svContainer scrollRectToVisible:CGRectMake(_svContainer.left, _svContainer.contentSize.height - 50, kScreenWidth, 50) animated:YES];
    }
    [self layoutTagviews];
}

#pragma mark - 删除标签
- (void)handlerButtonAction:(TTCheckBoxButton *)tagButton {
    
    switch (_type) {
        case TTTagView_Type_Edit: {
            
            _editingTagIndex = [_tagButtons indexOfObject:tagButton];
            CGRect buttonFrame = tagButton.frame;
            buttonFrame.size.height -= 5;
            
            // 自定义UIMenuController(删除按钮)
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteItemClicked:)];
            NSAssert([self becomeFirstResponder], @"Sorry, UIMenuController will not work with %@ since it cannot become first responder", self);
            [menuController setMenuItems:[NSArray arrayWithObject:resetMenuItem]];
            [menuController setTargetRect:buttonFrame inView:_svContainer];
            [menuController setMenuVisible:YES animated:YES];
        }
            break;
        case TTTagView_Type_Selected: {
            
            for (TTCheckBoxButton *button in _tagButtons) {
                button.selected = NO;
            }
            tagButton.selected = YES;
        }
            break;
        default: {
            
        }
            break;
    }

}


#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"endEditing" object:nil];
    
    if (!textField.text || [textField.text isEqualToString:@""]) {
        return NO;
    }
    
    if ([textField.text containsString:@" "]) {
        textField.text = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        return NO;
    }
    
    [self addTagToLast:textField.text];
    textField.text = nil;
    [self layoutTagviews];
    
    return NO;
}

#pragma mark - 这里限制标签的字数为18
- (void)textFieldDidFinishChange:(UITextField*)textField {
    
    NSString *lang = [[textField textInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            
            if (textField.text.length > 18) {
                textField.text = [textField.text substringToIndex:18];
            }
        }
    } else { // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        
        if (textField.text.length > 18) {
            textField.text = [textField.text substringToIndex:18];
        }
    }
    [self layoutTagviews];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // 标签中限制其输入空格
    if ([string isEqualToString:@" "]) {
        return NO;
    }
    NSString* string2 = [textField.text stringByReplacingCharactersInRange:range withString:string];
    CGRect frame = _tfInput.frame;
    frame.size.width = [textField.text sizeWithAttributes:@{NSFontAttributeName:_fontInput}].width + (_tfInput.layer.cornerRadius * 2.0f);
    frame.size.width = MAX(frame.size.width, _tagWidht);
    if (frame.size.width + _tagPaddingSize.width * 2 >= _svContainer.width - 30) {

        if (string2.length < textField.text.length) {
            
            return YES;
        } else {
            
            frame.size.width = MIN(frame.size.width, _svContainer.width);
            _tfInput.frame = frame;
            return NO;
        }
    
    } else {
        return YES;
    }
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"willEditing" object:nil];
    _editingTagIndex = _tagStrings.count;
    
    if (self.selectedBtn != nil) {
        [self.selectedBtn setSelected:NO];
        
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [self textFieldShouldReturn:textField];
    
}

#pragma mark UIMenuController
- (void)deleteItemClicked:(TTCheckBoxButton *)sender {
    
    
    if ([self.delegate respondsToSelector:@selector(deleteBtnClick:)] && _editingTagIndex < _tagStrings.count) {
        
        [self.delegate deleteBtnClick:_tagStrings[_editingTagIndex]];
    }
    
    if (![_tfInput isEditing] && _editingTagIndex < _tagStrings.count) {
        
        [self removeTag:_tagStrings[_editingTagIndex]];
    }
}

- (BOOL)canPerformAction:(SEL)selector withSender:(id)sender {
    
    if (selector == @selector(deleteItemClicked:)) {
        return YES;
    }
    return NO;
}

- (BOOL)canBecomeFirstResponder {
    
    return YES;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    if (self.selectedBtn != nil) {
        [self.selectedBtn setSelected:NO];
    }
    [self textFieldShouldReturn:_tfInput];
}


#pragma mark getter & setter
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    
    [super setBackgroundColor:backgroundColor];
    _svContainer.backgroundColor = backgroundColor;
}

- (void)setType:(TTTagView_Type)type {
    
    _type = type;
    switch (_type) {
            
        case TTTagView_Type_Edit: {
            
            for (UIButton* button in _tagButtons) {
                button.selected = NO;
            }
        }
            break;
            
        case TTTagView_Type_Selected: {
            
            for (UIButton *button in _tagButtons) {
                button.selected = [_tagStringsSelected containsObject:button.titleLabel.text];
            }
        }
            break;
        default: {
            
        }
            break;
    }
    [self layoutTagviews];
}


- (void)setBgColor:(UIColor *)bgColor {
    
    if (_bgColor == nil) {
        _bgColor = bgColor;
    }
    
    for (TTCheckBoxButton *button in _tagButtons) {
        button.colorBg = bgColor;
    }
    
}


- (void)setTagStringsSelected:(NSMutableArray *)tagStringsSelected {
    
    _tagStringsSelected = tagStringsSelected;
    switch (_type) {
            
        case TTTagView_Type_Selected: {
            
            for (UIButton *button in _tagButtons) {
                button.selected = [tagStringsSelected containsObject:button.titleLabel.text];
            }
        }
            break;
        default: {
            
        }
            break;
    }
}

#pragma mark - 从控制器传进来的需要被删除的标签
- (void)setDeleteString:(NSString *)deleteString {
    
    if (_deleteString != deleteString) {
        _deleteString = deleteString;
    }
    
    [self removeTag:deleteString];
}

@end
