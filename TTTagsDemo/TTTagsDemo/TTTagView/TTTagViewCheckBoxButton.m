//
//  TTTagViewCheckBoxButton.m
//  TTTagsDemo
//
//  Created by 赵春浩 on 2020/12/3.
//

#import "TTTagViewCheckBoxButton.h"

@implementation TTTagViewCheckBoxButton

+ (instancetype)tagButtonWithTag:(NSString *)tag {
    
    TTTagViewCheckBoxButton *tagBtn = [[TTTagViewCheckBoxButton alloc] init];
    
    return tagBtn;
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
