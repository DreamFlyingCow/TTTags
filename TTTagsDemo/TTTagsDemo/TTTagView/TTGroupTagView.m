//
//  TTGroupTagView.m
//  Tags
//
//  Created by 赵春浩 on 16/8/15.
//  Copyright © 2016年 Mr Zhao. All rights reserved.
//

#import "TTGroupTagView.h"

@interface TTTagViewCheckBoxButton :UIButton

@property (nonatomic, strong) UIColor* colorBg;
@property (nonatomic, strong) UIColor* colorText;
@property (strong, nonatomic) UIColor *borderColor;

@property (nonatomic, strong) UIColor* selColorBg;
@property (nonatomic, strong) UIColor* selColorText;
@property (strong, nonatomic) UIColor *selBorderColor;

@end


@implementation TTTagViewCheckBoxButton

- (void)setSelected:(BOOL)selected {
    
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

// 设置占位文本的位置
- (CGRect)textRectForBounds:(CGRect)bounds {
    
    return CGRectInset( bounds , 12.5 , 0 );
}

// 设置文本的位置
- (CGRect)editingRectForBounds:(CGRect)bounds {
    
    return CGRectInset( bounds , 12.5 , 0 );
}

@end


@interface TTGroupTagView()

@property (nonatomic, strong) UIScrollView* svContainer;

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

@end

@interface TTGroupTagView ()

// 当输入的文字过长时用来存储总长度的
@property (assign, nonatomic) CGFloat currentMaxLength;
/**
 *  是否是第一行
 */
@property (assign, nonatomic) BOOL isFirst;



@end

@implementation TTGroupTagView {
    
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



- (void)commonInit {
    
    // 默认的标签宽度
    _tagWidht = 80;
    // 默认的标签高度
    _tagHeight = 30;
    // 第一个参数是左右两个标签之间的间隔  第二个参数是上下两个标签之间的间隔
    _tagPaddingSize = CGSizeMake(10, 10);
    // 第一个参数表示标签内部text文本左右距离文本框的距离
    _textPaddingSize = CGSizeMake(12.5, 0);
    _fontTag = [UIFont systemFontOfSize:14];
    
    _bgColor = kColorRGB(0x999999);
    _selBgColor = kColorRGB(0xffffff);
    _textColor = kColorRGB(0xcccccc);
    _selTextColor = kColorRGB(0xffae00);
    _borderColor = kColorRGB(0xffffff);
    _selBorderColor = kColorRGB(0xffae00);
    
    
    _viewMaxHeight = MAXFLOAT;
    self.backgroundColor = kColorRGB(0xffffff);
    
    self.currentMaxLength = 0;
    
    _tagButtons = [NSMutableArray new];
    _tagStrings = [NSMutableArray new];
    _tagStringsSelected = [NSMutableArray new];
    
    {
        
        // 标签所在的view(UIScrollView)
        UIScrollView *sv = [[UIScrollView alloc] initWithFrame:self.bounds];
        sv.contentSize = sv.frame.size;
        sv.contentSize = CGSizeMake(sv.frame.size.width, 600);
        sv.indicatorStyle = UIScrollViewIndicatorStyleDefault;
        sv.backgroundColor = self.backgroundColor;
        // 垂直滚动条
        sv.showsVerticalScrollIndicator = YES;
        // 水平滚动条
        sv.showsHorizontalScrollIndicator = NO;
        [self addSubview:sv];
        _svContainer = sv;
    }
    
}


- (NSMutableArray *)tagStrings {
    
    return _tagStrings;
}

#pragma mark - 对标签视图重新布局
- (void)layoutTags {
    
    self.isFirst = YES;
    float oldContentHeight = _svContainer.contentSize.height;
    float offsetX = _tagPaddingSize.width,offsetY = _tagPaddingSize.height;
    for (int i = 0; i < _tagButtons.count; i ++) {
        TTTagViewCheckBoxButton *tagButton = _tagButtons[i];
        CGRect frame = tagButton.frame;
        self.isFirst = NO;
        
        if ((offsetX + tagButton.frame.size.width + _tagPaddingSize.width) <= kScreenWidth) {
            frame.origin.x = offsetX;
            frame.origin.y = offsetY;
            offsetX += tagButton.frame.size.width + _tagPaddingSize.width;
            
        } else if (i != 0) {
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
        
        tagButton.frame=frame;
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

// 添加标签按钮
- (TTTagViewCheckBoxButton *)tagButtonWithTag:(NSString *)tag {
    
    TTTagViewCheckBoxButton *tagBtn = [[TTTagViewCheckBoxButton alloc] init];
    
    tagBtn.colorBg = _bgColor;
    tagBtn.colorText = _textColor;
    tagBtn.borderColor = _borderColor;
    
    tagBtn.selColorBg = _selBgColor;
    tagBtn.selColorText = _selTextColor;
    tagBtn.selBorderColor = _selBorderColor;
    
    tagBtn.selected = NO;
    [tagBtn.titleLabel setFont:_fontTag];
    [tagBtn addTarget:self action:@selector(handlerTagButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [tagBtn setTitle:tag forState:UIControlStateNormal];
    CGRect btnFrame = CGRectMake(0, 0, 0, 0);
    btnFrame.size.height = _tagHeight;
    tagBtn.layer.cornerRadius = btnFrame.size.height * 0.5f;
    
    btnFrame.size.width = [tagBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_fontTag}].width + (tagBtn.layer.cornerRadius * 2.0f);
    
    tagBtn.frame = btnFrame;
    return tagBtn;
}
/**
 *  标签按钮的点击
 *
 *  @param sender 选中 <-> 未选中 之间的转换
 */
- (void)handlerTagButtonEvent:(TTTagViewCheckBoxButton*)sender {
    
    BOOL isSelected = sender.selected;
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(buttonClick:and:)]) {
        [self.delegate buttonClick:sender.titleLabel.text and:isSelected];
    }
    
}

#pragma mark - 添加标签
- (void)addTags:(NSArray *)tags {
    
    for (NSString *tag in tags) {
        [self addTagToLast:tag];
    }
    
    [self layoutTags];
    
}

- (void)addTagToLast:(NSString *)tag {
    
    NSArray *result = [_tagStrings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == %@", tag]];
    if (result.count == 0) {
        [_tagStrings addObject:tag];
        
        TTTagViewCheckBoxButton* tagButton = [self tagButtonWithTag:tag];
        [_svContainer addSubview:tagButton];
        [_tagButtons addObject:tagButton];

    }
    [self layoutTags];
}

#pragma mark setter方法
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    
    [super setBackgroundColor:backgroundColor];
    _svContainer.backgroundColor = backgroundColor;
}

- (void)setTagStringsSelected:(NSMutableArray *)tagStringsSelected {
    
    _tagStringsSelected = tagStringsSelected;
    
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
            TTTagViewCheckBoxButton *button = self.tagButtons[i];
            button.selected = NO;
            return;
        }
    }
}




@end
