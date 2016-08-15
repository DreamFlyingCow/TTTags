//
//  TTTagView.m
//  Tags
//
//  Created by 赵春浩 on 16/8/15.
//  Copyright © 2016年 Mr Zhao. All rights reserved.
//

#import "TTTagView.h"

@interface TTCheckBoxButton :UIButton

@property (nonatomic, strong) UIColor* colorBg;
@property (nonatomic, strong) UIColor* colorText;
@property (strong, nonatomic) UIColor *borderColor;


@property (nonatomic, strong) UIColor* selColorBg;
@property (nonatomic, strong) UIColor* selColorText;
@property (strong, nonatomic) UIColor *selBorderColor;

@end


@implementation TTCheckBoxButton

-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        [self setBackgroundColor:_selColorBg];
        self.layer.borderColor=_selBorderColor.CGColor;
        self.layer.borderWidth=1;
        [self setTitleColor:_selColorText forState:UIControlStateSelected];
    } else {
        [self setBackgroundColor:_colorText];
        self.layer.borderColor=_colorBg.CGColor;
        self.layer.borderWidth=1;
        [self setTitleColor:_colorBg forState:UIControlStateNormal];
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

// 容器view
@property (nonatomic, strong) UIScrollView* svContainer;
// 标签按钮的数组
@property (nonatomic, strong) NSMutableArray *tagButtons;
// 用来记录标签上边的文本
@property (nonatomic, strong) NSMutableArray *tagStrings;
// 标记被选中的标签
@property (nonatomic, strong) NSMutableArray *tagStringsSelected;
// 
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

@implementation TTTagView
{
    // 正在编辑的标签的下标
    NSInteger _editingTagIndex;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

#pragma mark - 初始化一些控件
- (void)commonInit
{
    
    /**
     *  默认的标签类型(编辑)
     */
    _type=TTTagView_Type_Edit;
    /**
     *  默认的标签宽度
     */
    _tagWidht= 85;
    /**
     *  默认的标签高度
     */
    _tagHeight= 30;
    /**
     *  第一个参数是左右两个标签之间的间隔  第二个参数是上下两个标签之间的间隔
     */
    _tagPaddingSize=CGSizeMake(10, 10);
    /**
     *  第一个参数表示标签内部text文本左右距离文本框的距离
     */
    _textPaddingSize=CGSizeMake(12.5, 0);
    /**
     *  标签字体大小
     */
    _fontTag=[UIFont systemFontOfSize:14];
    /**
     *  输入标签的字体大小
     */
    _fontInput=[UIFont systemFontOfSize:14];
    /**
     *  标签的颜色(输入完成)
     */
    _colorTag=kColorRGB(0xffffff);
    /**
     *  输入标签的颜色
     */
    _colorInput=kColorRGB(0x2ab44e);
    /**
     *  输入标签占位字符的颜色
     */
    _colorInputPlaceholder=kColorRGB(0x2ab44e);
    /**
     *  标签的背景颜色
     */
    _colorTagBg=kColorRGB(0x2ab44e);
    /**
     *  输入标签的背景颜色
     */
    _colorInputBg = kColorRGB(0xbbbbbb);
    _colorInputBoard = kColorRGB(0x2ab44e);
    _viewMaxHeight = 130;
    self.backgroundColor=kColorRGB(0xffffff);
    
    self.currentMaxLength = 0;
    /**
     *  标签中的按钮
     */
    _tagButtons=[NSMutableArray new];
    /**
     *  标签上显示的文字
     */
    _tagStrings=[NSMutableArray new];
    /**
     *  被选中的标签
     */
    _tagStringsSelected=[NSMutableArray new];
    
    {
        
        /**
         *  标签所在的view(UIScrollView)
         */
        UIScrollView* sv = [[UIScrollView alloc] initWithFrame:self.bounds];
        sv.contentSize=sv.frame.size;
//        sv.contentSize=CGSizeMake(sv.frame.size.width, self.height);
        self.changeHeight = sv.contentSize.height;
        sv.indicatorStyle=UIScrollViewIndicatorStyleDefault;
        sv.backgroundColor = self.backgroundColor;
        // 取消弹簧效果
        sv.bounces = NO;
        // 垂直滚动条
        sv.showsVerticalScrollIndicator = YES;
        // 水平滚动条
        sv.showsHorizontalScrollIndicator = NO;
        [self addSubview:sv];
        _svContainer=sv;
    }
    {
        // 默认的标签
        UITextField* tf = [[TTTextField alloc] initWithFrame:CGRectMake(0, 0, _tagWidht, _tagHeight)];
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        [tf addTarget:self action:@selector(textFieldDidFinishChange:)forControlEvents:UIControlEventEditingChanged];
        tf.delegate = self;
        tf.placeholder=@"添加标签";
        
        tf.returnKeyType = UIReturnKeyDone;
        [_svContainer addSubview:tf];
        _tfInput=tf;
    }
    {
        _gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        _gestureRecognizer.numberOfTapsRequired=1;
        [self addGestureRecognizer:_gestureRecognizer];
    }
}


-(NSMutableArray *)tagStrings{
      switch (_type) {
        case TTTagView_Type_Edit:
        {
            return _tagStrings;
        }
            break;
        case TTTagView_Type_Display:
        {
            return nil;
        }
            break;
        case TTTagView_Type_Selected:
        {
            [_tagStringsSelected removeAllObjects];
            for (TTCheckBoxButton* button in _tagButtons) {
                if (button.selected) {
                    [_tagStringsSelected addObject:button.titleLabel.text];
                    break;
                }
            }
            return _tagStringsSelected;
        }
            break;
              
        default:
        {
            
        }
            break;
    }
    return nil;
}

#pragma mark - 对标签进行重新布局
-(void)layoutTagviews{
    self.isFirst = YES;
    float oldContentHeight=_svContainer.contentSize.height;
    float offsetX=_tagPaddingSize.width,offsetY=_tagPaddingSize.height;
    for (int i=0; i<_tagButtons.count; i++) {
        TTCheckBoxButton* tagButton=_tagButtons[i];
        CGRect frame=tagButton.frame;
        self.isFirst = NO;

            if ((offsetX+tagButton.frame.size.width+_tagPaddingSize.width)
                <=_svContainer.contentSize.width) {
                frame.origin.x=offsetX;
                frame.origin.y=offsetY;
                offsetX+=tagButton.frame.size.width+_tagPaddingSize.width;
            }else if (i != 0) {
                offsetX=_tagPaddingSize.width;
                offsetY+=_tagHeight+_tagPaddingSize.height;
                
                frame.origin.x=offsetX;
                frame.origin.y=offsetY;
                offsetX+=tagButton.frame.size.width+_tagPaddingSize.width;
            } else {
                offsetX=_tagPaddingSize.width;
                frame.origin.x=offsetX;
                frame.origin.y=offsetY;
                offsetX+=tagButton.frame.size.width+_tagPaddingSize.width;
                
            }

        tagButton.frame=frame;
    }
    _tfInput.hidden=(_type!=TTTagView_Type_Edit);
    if (_type==TTTagView_Type_Edit) {
        _tfInput.backgroundColor=_colorInputBg;
        _tfInput.textColor=_colorInput;
        _tfInput.font=_fontInput;
        
        [_tfInput setValue:_colorInputPlaceholder forKeyPath:@"_placeholderLabel.textColor"];
        _tfInput.layer.cornerRadius = _tfInput.frame.size.height * 0.5f;
        _tfInput.layer.borderColor=_colorInputBoard.CGColor;
        _tfInput.layer.borderWidth=1;
        {
            CGRect frame=_tfInput.frame;
            frame.size.width = [_tfInput.text sizeWithAttributes:@{NSFontAttributeName:_fontInput}].width + _tfInput.layer.cornerRadius * 2.0f + _textPaddingSize.width * 2.0;
            frame.size.width=MAX(frame.size.width, _tagWidht);
            _tfInput.frame=frame;
        }
        CGRect frame=_tfInput.frame;

            if ((offsetX+_tfInput.frame.size.width+_tagPaddingSize.width)
                <=_svContainer.contentSize.width) {
                frame.origin.x=offsetX;
                frame.origin.y=offsetY;
            }else if (!self.isFirst) {
                offsetX=_tagPaddingSize.width;
                offsetY+=_tagHeight+_tagPaddingSize.height;
                
                frame.origin.x=offsetX;
                frame.origin.y=offsetY;
            } else {
                offsetX=_tagPaddingSize.width;
                frame.origin.x=offsetX;
                frame.origin.y=offsetY;
            }
        _tfInput.frame=frame;
        
    }
    
    _svContainer.contentSize=CGSizeMake(_svContainer.contentSize.width, offsetY+_tagHeight+_tagPaddingSize.height);
    {
        CGRect frame=_svContainer.frame;
        frame.size.height=_svContainer.contentSize.height;
        frame.size.height=MIN(frame.size.height, _viewMaxHeight);
        _svContainer.frame=frame;
    }
    {
        CGRect frame=self.frame;
        frame.size.height=_svContainer.frame.size.height;
        self.frame=frame;
    }

    if (oldContentHeight != _svContainer.contentSize.height) {
        CGPoint bottomOffset = CGPointMake(0, _svContainer.contentSize.height - _svContainer.bounds.size.height);
        [_svContainer setContentOffset:bottomOffset animated:YES];
    }
    
    self.changeHeight = _svContainer.frame.size.height;
}

#pragma mark - 在textField上边添加一个按钮
- (TTCheckBoxButton *)tagButtonWithTag:(NSString *)tag
{
    TTCheckBoxButton *tagBtn = [[TTCheckBoxButton alloc] init];
    tagBtn.colorBg=_colorTagBg;
    tagBtn.colorText=_colorTag;
    tagBtn.borderColor = _colorInputBg;
    
    tagBtn.selColorBg = _colorInputBg;
    tagBtn.selColorText = _mainColor;
    tagBtn.selBorderColor = _mainColor;
    tagBtn.selected=YES;
    [tagBtn.titleLabel setFont:_fontTag];
    [tagBtn addTarget:self action:@selector(handlerTagButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [tagBtn setTitle:tag forState:UIControlStateSelected];
    
    CGRect btnFrame = CGRectMake(0, 0, 0, 0);
    btnFrame.size.height = _tagHeight;
    tagBtn.layer.cornerRadius = btnFrame.size.height * 0.5f;
    btnFrame.size.width = [tagBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_fontTag}].width + (tagBtn.layer.cornerRadius * 2.0f);
    
    tagBtn.frame=btnFrame;
    return tagBtn;
}

#pragma mark - 按钮的点击事件
- (void)handlerTagButtonEvent:(TTCheckBoxButton*)sender
{
    if (self.selectedBtn != nil) {
        [self.selectedBtn setTitleColor:_mainColor forState:UIControlStateSelected];
        [self.selectedBtn setBackgroundColor:_colorInputBg];
    }

    self.selectedBtn = sender;
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [sender setBackgroundColor:_mainColor];
    
    NSLog(@"按钮点击");
    
}
#pragma mark action 添加标签

- (void)addTags:(NSArray *)tags{
    for (NSString *tag in tags)
    {
        [self addTagToLast:tag];
    }
    
    [self layoutTagviews];
    
}

- (void)addTags:(NSArray *)tags selectedTags:(NSArray*)selectedTags{
    [self addTags:tags];
    self.tagStringsSelected=[NSMutableArray arrayWithArray:selectedTags];
}

- (void)addTagToLast:(NSString *)tag{
    NSArray *result = [_tagStrings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == %@", tag]];
    if (result.count == 0)
    {
        [_tagStrings addObject:tag];
        [_svContainer scrollRectToVisible:CGRectMake(_svContainer.left, _svContainer.contentSize.height - 50, kScreenWidth, 50) animated:YES];
        if ([self.delegate respondsToSelector:@selector(finishInput:)]) {
            [self.delegate finishInput:tag];
        }
        
        TTCheckBoxButton* tagButton=[self tagButtonWithTag:tag];
        [tagButton addTarget:self action:@selector(handlerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_svContainer addSubview:tagButton];
        [_tagButtons addObject:tagButton];
        
        switch (_type) {
            case TTTagView_Type_Selected:
            {
                tagButton.selected=NO;
            }
                break;
            default:
                break;
        }
    }
    [self layoutTagviews];
}
#pragma mark - 删除标签
- (void)removeTags:(NSArray *)tags{
    for (NSString *tag in tags)
    {
        [self removeTag:tag];
    }
    [self layoutTagviews];
}
- (void)removeTag:(NSString *)tag{
    NSArray *result = [_tagStrings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == %@", tag]];
    if (result)
    {
        NSInteger index=[_tagStrings indexOfObject:tag];
        [_tagStrings removeObjectAtIndex:index];
        [_tagButtons[index] removeFromSuperview];
        [_tagButtons removeObjectAtIndex:index];
    }
    [self layoutTagviews];
}

#pragma mark - 删除标签
-(void)handlerButtonAction:(TTCheckBoxButton*)tagButton{
    
    switch (_type) {
        case TTTagView_Type_Edit:
        {
            [self becomeFirstResponder];
            _editingTagIndex=[_tagButtons indexOfObject:tagButton];
            CGRect buttonFrame=tagButton.frame;
            buttonFrame.size.height-=5;
            
            // 自定义UIMenuController(删除按钮)
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteItemClicked:)];
            NSAssert([self becomeFirstResponder], @"Sorry, UIMenuController will not work with %@ since it cannot become first responder", self);
            [menuController setMenuItems:[NSArray arrayWithObject:resetMenuItem]];
            [menuController setTargetRect:buttonFrame inView:_svContainer];
            [menuController setMenuVisible:YES animated:YES];
        }
            break;
        case TTTagView_Type_Selected:
        {
            if (tagButton.selected) {
                tagButton.selected=NO;
            }else{
                for (TTCheckBoxButton* button in _tagButtons) {
                    button.selected=NO;
                }
                tagButton.selected=YES;
            }
        }
            break;
        default:
        {
            
        }
            break;
    }

}


#pragma mark UITextFieldDelegate


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (!textField.text
        || [textField.text isEqualToString:@""]) {
        return NO;
    }
    if ([textField.text containsString:@" "]) {
        textField.text = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        return NO;
    }
    [self addTagToLast:textField.text];
    textField.text=nil;
    [self layoutTagviews];
    return NO;
}

-(void)textFieldDidFinishChange:(UITextField*)textField{
    
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
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
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
    NSString* string2= [textField.text stringByReplacingCharactersInRange:range withString:string];
    CGRect frame=_tfInput.frame;
    frame.size.width = [textField.text sizeWithAttributes:@{NSFontAttributeName:_fontInput}].width + (_tfInput.layer.cornerRadius * 2.0f);
    frame.size.width=MAX(frame.size.width, _tagWidht);
    if (frame.size.width+_tagPaddingSize.width*2 >= _svContainer.width - 30) {

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
    if (self.selectedBtn != nil) {
        [self.selectedBtn setTitleColor:_mainColor forState:UIControlStateSelected];
        [self.selectedBtn setBackgroundColor:_colorInputBg];
    }
    return YES;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if ([_delegate conformsToProtocol:@protocol(UITextFieldDelegate)]
        && [_delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [_delegate performSelector:@selector(textFieldDidBeginEditing:) withObject:textField];
    }
}


-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self layoutTagviews];
    if ([_delegate conformsToProtocol:@protocol(UITextFieldDelegate)]
        && [_delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [_delegate performSelector:@selector(textFieldDidEndEditing:) withObject:textField];
    }
}
#pragma mark UIMenuController

- (void) deleteItemClicked:(TTCheckBoxButton *) sender {
    
    if ([self.delegate respondsToSelector:@selector(deleteBtnClick:)]) {
        [self.delegate deleteBtnClick:_tagStrings[_editingTagIndex]];
    }
    
    [self removeTag:_tagStrings[_editingTagIndex]];
}
- (BOOL) canPerformAction:(SEL)selector withSender:(id) sender {
    if (selector == @selector(deleteItemClicked:) /*|| selector == @selector(copy:)*/ /*<--enable that if you want the copy item */) {
        return YES;
    }
    return NO;
}
- (BOOL) canBecomeFirstResponder {
    return YES;
}
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    [self.selectedBtn setTitleColor:_mainColor forState:UIControlStateSelected];
    [self.selectedBtn setBackgroundColor:_colorInputBg];
    [self textFieldShouldReturn:_tfInput];
}


#pragma mark getter & setter
-(void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:backgroundColor];
    _svContainer.backgroundColor=backgroundColor;
}
-(void)setType:(TTTagView_Type)type{
    _type=type;
    switch (_type) {
        case TTTagView_Type_Edit:
        {
            for (UIButton* button in _tagButtons) {
                button.selected=YES;
            }
        }
            break;
        case TTTagView_Type_Display:
        {
            for (UIButton* button in _tagButtons) {
                button.selected=YES;
            }
        }
            break;
        case TTTagView_Type_Selected:
        {
            for (UIButton* button in _tagButtons) {
                button.selected=[_tagStringsSelected containsObject:button.titleLabel.text];
            }
        }
            break;
        default:
        {
            
        }
            break;
    }
    [self layoutTagviews];
}
-(void)setColorTagBg:(UIColor *)colorTagBg{
    _colorTagBg=colorTagBg;
    for (TTCheckBoxButton* button in _tagButtons) {
        button.colorBg=colorTagBg;
    }
}
-(void)setColorTag:(UIColor *)colorTag{
    _colorTag=colorTag;
    for (TTCheckBoxButton* button in _tagButtons) {
        button.colorText=colorTag;
    }
}
-(void)setTagStringsSelected:(NSMutableArray *)tagStringsSelected{
    _tagStringsSelected=tagStringsSelected;
    switch (_type) {
        case TTTagView_Type_Selected:
        {
            for (UIButton* button in _tagButtons) {
                button.selected=[tagStringsSelected containsObject:button.titleLabel.text];
            }
        }
            break;
        default:
        {
            
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
