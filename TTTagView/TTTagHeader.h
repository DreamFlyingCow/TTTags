//
//  TTTagHeader.h
//  TTTagsDemo
//
//  Created by 赵春浩 on 2020/12/3.
//

#ifndef TTTagHeader_h
#define TTTagHeader_h

//屏幕的物理宽度
#define     TTScreenWidth            [UIScreen mainScreen].bounds.size.width
//屏幕的物理高度
#define     TTScreenHeight           [UIScreen mainScreen].bounds.size.height

#define     TTColor(a)              [UIColor colorWithRed:a/255.0f green:a/255.0f blue:a/255.0f alpha:1.0f]

#define     TTCustomColor(a,b,c)     [UIColor colorWithRed:a/255.0f green:b/255.0f blue:c/255.0f alpha:1.0f]

#define     TTRandomColor            [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1.0]

#define TTColorRGBA(c,a) [UIColor colorWithRed:((c>>16)&0xFF)/255.0    \
green:((c>>8)&0xFF)/255.0    \
blue:(c&0xFF)/255.0         \
alpha:a]
#define TTColorRGB(c)    [UIColor colorWithRed:((c>>16)&0xFF)/255.0    \
green:((c>>8)&0xFF)/255.0    \
blue:(c&0xFF)/255.0         \
alpha:1.0]

#import "UIView+TTFrame.h"
#import "TTTextField.h"
#import "TTButton.h"


#endif /* TTTagHeader_h */
