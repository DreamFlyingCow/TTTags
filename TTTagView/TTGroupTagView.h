//
//  TTGroupTagView.h
//  Tags
//
//  Created by 赵春浩 on 16/8/15.
//  Copyright © 2016年 Mr Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TTGroupTagViewDelegate <NSObject>

@optional
/**
 *  点击标签列表中的标签, 对上边的标签视图中的标签做出反应
 *
 *  @param string   点击的标签的文本
 *  @param isDelete 是删除还是添加
 */
- (void)buttonClick:(NSString *)string and:(BOOL)isDelete;

@end


@interface TTGroupTagView : UIView

@property (nonatomic,   weak) id <TTGroupTagViewDelegate> delegate;

@property (nonatomic, assign) CGFloat changeHeight;

@property (nonatomic, assign) float tagWidht;
@property (nonatomic, assign) float tagHeight;

@property (nonatomic, assign) float viewMaxHeight;

@property (nonatomic, assign) CGSize tagPaddingSize;
@property (nonatomic, assign) CGSize textPaddingSize;

/**
 *  字体大小
 */
@property (nonatomic, strong) UIFont *fontTag;
/**
 *  未被选中时的背景颜色
 */
@property (nonatomic, strong) UIColor *bgColor;
/**
 *  未被选中时的文字颜色
 */
@property (nonatomic, strong) UIColor *textColor;
/**
 *  未被选中时的边框颜色
 */
@property (nonatomic, strong) UIColor *borderColor;
/**
 *  被选中时的背景颜色
 */
@property (nonatomic, strong) UIColor *selBgColor;
/**
 *  被选中时的文字颜色
 */
@property (nonatomic, strong) UIColor *selTextColor;
/**
 *  被选中时的边框颜色
 */
@property (nonatomic, strong) UIColor *selBorderColor;

@property (copy, nonatomic) NSString *deleteString;


- (void)addTags:(NSArray *)tags;
- (void)setTagStringsSelected:(NSMutableArray *)tagStringsSelected;
- (NSMutableArray *)tagStrings;


@end
