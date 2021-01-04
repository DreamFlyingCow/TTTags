//
//  TTTextField.m
//  TTTagsDemo
//
//  Created by 赵春浩 on 2020/12/3.
//

#import "TTTextField.h"

@implementation TTTextField

// 设置占位文本的位置
- (CGRect)textRectForBounds:(CGRect)bounds {

    return CGRectInset(bounds, 12.5, 0);
}

// 设置文本的位置
- (CGRect)editingRectForBounds:(CGRect)bounds {

    return CGRectInset(bounds, 12.5, 0);
}

@end
