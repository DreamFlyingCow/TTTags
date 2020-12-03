//
//  TTTagViewCheckBoxButton.h
//  TTTagsDemo
//
//  Created by 赵春浩 on 2020/12/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTTagViewCheckBoxButton : UIButton

@property (nonatomic, strong) UIColor *colorBg;         // 默认按钮背景色
@property (nonatomic, strong) UIColor *colorText;       // 默认按钮字体颜色
@property (nonatomic, strong) UIColor *borderColor;     // 默认按钮边框颜色

@property (nonatomic, strong) UIColor *selColorBg;      // 选中时按钮背景颜色
@property (nonatomic, strong) UIColor *selColorText;    // 选中时按钮字体颜色
@property (nonatomic, strong) UIColor *selBorderColor;  // 选中时按钮边框颜色

@property (nonatomic, strong) id buttonTag;             // 按钮的标记
// 带标记初始化方法
+ (instancetype)tagButtonWithTag:(id)buttonTag;

@end

NS_ASSUME_NONNULL_END
