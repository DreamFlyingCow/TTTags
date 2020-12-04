//
//  TTButton.m
//  TTTagsDemo
//
//  Created by 赵春浩 on 2020/12/3.
//

#import "TTButton.h"

@implementation TTButton

+ (instancetype)tagButtonWithTag:(id)buttonTag {
    
    TTButton *button = [[TTButton alloc] init];
    button.buttonTag = buttonTag;
    return button;
}

- (void)setSelected:(BOOL)selected {
    
    [super setSelected:selected];
    if (selected) {
        [self setBackgroundColor:self.selColorBg];
        self.layer.borderColor = self.selBorderColor.CGColor;
        self.layer.borderWidth = 1;
        [self setTitleColor:self.selColorText forState:UIControlStateSelected];
    } else {
        [self setBackgroundColor:self.colorBg];
        self.layer.borderColor = self.borderColor.CGColor;
        self.layer.borderWidth = 1;
        [self setTitleColor:self.colorText forState:UIControlStateNormal];
    }
    [self setNeedsDisplay];
}


@end
