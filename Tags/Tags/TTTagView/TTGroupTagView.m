//
//  TTGroupTagView.m
//  Tags
//
//  Created by 赵春浩 on 16/8/15.
//  Copyright © 2016年 Mr Zhao. All rights reserved.
//

#import "TTGroupTagView.h"

@interface SMTagViewCheckBoxButton :UIButton
@property (nonatomic, strong) UIColor* colorBg;
@property (nonatomic, strong) UIColor* colorText;
@property (strong, nonatomic) UIColor *borderColor;

@property (nonatomic, strong) UIColor* selColorBg;
@property (nonatomic, strong) UIColor* selColorText;
@property (strong, nonatomic) UIColor *selBorderColor;

@end


@implementation SMTagViewCheckBoxButton
-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        [self setBackgroundColor:_selColorBg];
        self.layer.borderColor=_selBorderColor.CGColor;
        self.layer.borderWidth=1;
        [self setTitleColor:_selColorText forState:UIControlStateSelected];
    } else {
        [self setBackgroundColor:_borderColor];
        self.layer.borderColor=_colorText.CGColor;
        self.layer.borderWidth=1;
        [self setTitleColor:_colorBg forState:UIControlStateNormal];
    }
    [self setNeedsDisplay];
}
@end

@interface SMTextField : UITextField

@end
@implementation SMTextField

// placeholder position
// 设置占位文本的位置
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 12.5 , 0 );
}

// text position
// 设置文本的位置
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 12.5 , 0 );
}

@end


@interface TTGroupTagView()<UITextFieldDelegate>

@property (nonatomic, strong) UIScrollView* svContainer;

// 标签按钮的数组
@property (nonatomic, strong) NSMutableArray *tagButtons;
// 用来记录标签上边的文本
@property (nonatomic, strong) NSMutableArray *tagStrings;
// 标记被选中的标签
@property (nonatomic, strong) NSMutableArray *tagStringsSelected;



//
@property (nonatomic) UITapGestureRecognizer *gestureRecognizer;

@end

@interface TTGroupTagView ()

// 当输入的文字过长时用来存储总长度的
@property (assign, nonatomic) CGFloat currentMaxLength;
@property (assign, nonatomic) BOOL isFirst;



@end

@implementation TTGroupTagView
{
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



- (void)commonInit
{
    
    // 默认的标签宽度
    _tagWidht= 80;
    // 默认的标签高度
    _tagHeight= 30;
    // 第一个参数是左右两个标签之间的间隔  第二个参数是上下两个标签之间的间隔
    _tagPaddingSize=CGSizeMake(10, 10);
    // 第一个参数表示标签内部text文本左右距离文本框的距离
    _textPaddingSize=CGSizeMake(12.5, 0);
    _fontTag=[UIFont systemFontOfSize:14];
    _fontInput=[UIFont systemFontOfSize:14];
    _colorTag=kColorRGB(0xffffff);
    _colorInput=kColorRGB(0x2ab44e);
    _colorInputPlaceholder=kColorRGB(0x2ab44e);
    _colorTagBg=kColorRGB(0x2ab44e);
    _colorInputBg=kColorRGB(0xbbbbbb);
    _colorInputBoard=kColorRGB(0x2ab44e);
    _viewMaxHeight= 100000;
    self.backgroundColor=kColorRGB(0xffffff);
    
    self.currentMaxLength = 0;
    
    _tagButtons=[NSMutableArray new];
    _tagStrings=[NSMutableArray new];
    _tagStringsSelected=[NSMutableArray new];
    
    {
        
        // 标签所在的view(UIScrollView)
        UIScrollView* sv = [[UIScrollView alloc] initWithFrame:self.bounds];
        sv.contentSize=sv.frame.size;
        sv.contentSize=CGSizeMake(sv.frame.size.width, 600);
        sv.indicatorStyle=UIScrollViewIndicatorStyleDefault;
        sv.backgroundColor = self.backgroundColor;
        // 垂直滚动条
        sv.showsVerticalScrollIndicator = YES;
        // 水平滚动条
        sv.showsHorizontalScrollIndicator = NO;
        [self addSubview:sv];
        _svContainer=sv;
    }
    {
        // 默认的标签
        UITextField* tf = [[SMTextField alloc] initWithFrame:CGRectMake(0, 0, _tagWidht, _tagHeight)];
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        [tf addTarget:self action:@selector(textFieldDidFinishChange:)forControlEvents:UIControlEventEditingChanged];
        tf.delegate = self;
        tf.placeholder=@"New Tag";
        
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

#pragma mark -
-(NSMutableArray *)tagStrings{
    
    return _tagStrings;
}


- (void)layoutTags {
    [_tfInput removeFromSuperview];
    self.isFirst = YES;
    float oldContentHeight=_svContainer.contentSize.height; // 600
    float offsetX=_tagPaddingSize.width,offsetY=_tagPaddingSize.height; // 5,  5
    for (int i=0; i<_tagButtons.count; i++) {
        SMTagViewCheckBoxButton* tagButton=_tagButtons[i];
        CGRect frame=tagButton.frame;
        self.isFirst = NO;
        
        if ((offsetX+tagButton.frame.size.width+_tagPaddingSize.width)
            <=kScreenWidth) {
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

- (SMTagViewCheckBoxButton *)tagButtonWithTag:(NSString *)tag
{
    SMTagViewCheckBoxButton *tagBtn = [[SMTagViewCheckBoxButton alloc] init];
    tagBtn.colorBg=_colorTagBg;
    tagBtn.colorText=_colorTag;
    tagBtn.borderColor = _colorInputBg;
    
    tagBtn.selColorBg = _colorInputBg;
    tagBtn.selColorText = _colorInput;
    tagBtn.selBorderColor = _colorInput;
    
    tagBtn.selected=NO;
    [tagBtn.titleLabel setFont:_fontTag];
    [tagBtn addTarget:self action:@selector(handlerTagButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [tagBtn setTitle:tag forState:UIControlStateNormal];
    CGRect btnFrame = CGRectMake(0, 0, 0, 0);
    btnFrame.size.height = _tagHeight;
    tagBtn.layer.cornerRadius = btnFrame.size.height * 0.5f;
    
    btnFrame.size.width = [tagBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_fontTag}].width + (tagBtn.layer.cornerRadius * 2.0f);
    
    tagBtn.frame=btnFrame;
    return tagBtn;
}
- (void)handlerTagButtonEvent:(SMTagViewCheckBoxButton*)sender
{
    BOOL isSelected = sender.selected;
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(buttonClick:and:)]) {
        [self.delegate buttonClick:sender.titleLabel.text and:isSelected];
    }
    
    NSLog(@"按钮点击");
    
}
#pragma mark action

- (void)addTags:(NSArray *)tags{
    for (NSString *tag in tags)
    {
        [self addTagToLast:tag];
    }
    
    [self layoutTags];
    
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
        
        SMTagViewCheckBoxButton* tagButton=[self tagButtonWithTag:tag];
        [tagButton addTarget:self action:@selector(handlerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_svContainer addSubview:tagButton];
        [_tagButtons addObject:tagButton];

    }
    [self layoutTags];
}

- (void)removeTags:(NSArray *)tags{
    for (NSString *tag in tags)
    {
        [self removeTag:tag];
    }
    [self layoutTags];
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
    [self layoutTags];
}


-(void)handlerButtonAction:(SMTagViewCheckBoxButton*)tagButton{

    
}


#pragma mark UITextFieldDelegate


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (!textField.text
        || [textField.text isEqualToString:@""]) {
        return NO;
    }
    [self addTagToLast:textField.text];
    textField.text=nil;
    [self layoutTags];
    return NO;
}

-(void)textFieldDidFinishChange:(UITextField*)textField{
    [self layoutTags];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString* string2= [textField.text stringByReplacingCharactersInRange:range withString:string];
    CGRect frame=_tfInput.frame;
    frame.size.width = [textField.text sizeWithAttributes:@{NSFontAttributeName:_fontInput}].width + (_tfInput.layer.cornerRadius * 2.0f);
    frame.size.width=MAX(frame.size.width, _tagWidht);
    if (frame.size.width+_tagPaddingSize.width*2 >= _svContainer.width - 30) {
        NSLog(@"!!!  _tfInput width tooooooooo large");
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

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if ([_delegate conformsToProtocol:@protocol(UITextFieldDelegate)]
        && [_delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [_delegate performSelector:@selector(textFieldDidBeginEditing:) withObject:textField];
    }
}


-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self layoutTags];
    if ([_delegate conformsToProtocol:@protocol(UITextFieldDelegate)]
        && [_delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [_delegate performSelector:@selector(textFieldDidEndEditing:) withObject:textField];
    }
}

#pragma mark UIMenuController

- (void) deleteItemClicked:(id) sender {
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
}

#pragma mark getter & setter
-(void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:backgroundColor];
    _svContainer.backgroundColor=backgroundColor;
}

-(void)setColorTagBg:(UIColor *)colorTagBg{
    _colorTagBg=colorTagBg;
    
}
-(void)setColorTag:(UIColor *)colorTag{
    _colorTag=colorTag;
    
}
-(void)setTagStringsSelected:(NSMutableArray *)tagStringsSelected{
    
    _tagStringsSelected=tagStringsSelected;
    for (NSString *str in tagStringsSelected) {
        for (int i = 0; i < self.tagStrings.count; i ++) {
            if ([str isEqualToString:self.tagStrings[i]]) {
                if ([self.tagButtons[i] isSelected] == NO ) {
                    [self.tagButtons[i] setSelected:YES];
                }
            }
        }
    }
    
}

- (void)setDeleteString:(NSString *)deleteString {
    if (_deleteString != deleteString) {
        _deleteString = deleteString;
    }
    
    for (int i = 0; i < self.tagStrings.count; i ++) {
        if ([deleteString isEqualToString:self.tagStrings[i]]) {
            SMTagViewCheckBoxButton *button = self.tagButtons[i];
            button.selected = NO;
            return;
        }
    }
}


@end
