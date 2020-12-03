//
//  TTTagViewCheckBoxButton.h
//  TTTagsDemo
//
//  Created by 赵春浩 on 2020/12/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTTagViewCheckBoxButton : UIButton

@property (nonatomic, strong) UIColor *colorBg;
@property (nonatomic, strong) UIColor *colorText;

@property (nonatomic, strong) UIColor *borderColor;

@property (nonatomic, strong) UIColor *selColorBg;
@property (nonatomic, strong) UIColor *selColorText;
@property (nonatomic, strong) UIColor *selBorderColor;

+ (instancetype)tagButtonWithTag:(NSString *)tag;

@end

NS_ASSUME_NONNULL_END
