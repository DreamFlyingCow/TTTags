//
//  TTTagView.h
//  Tags
//
//  Created by 赵春浩 on 16/8/15.
//  Copyright © 2016年 Mr Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TTTagViewDelegate <NSObject>

@optional
/**
 *  点击标签删除按钮之后的事件处理(主要处理上下标签的对应关系)
 *
 *  @param string 被点击删除的标签文字
 */
- (void)deleteBtnClick:(NSString *)string;
/**
 *  输入完成之后, 也是为了处理上边输入的标签, 如果下边的列表中有的话, 就要将下边的标签设置为选中状态
 *
 *  @param string 当前输入的标签
 */
- (void)finishInput:(NSString *)string;

@end

/**
 标签的当前状态
 */
typedef enum {
    // 编辑状态
    TTTagView_Type_Edit,
    // 选中状态
    TTTagView_Type_Selected
    
} TTTagView_Type;

@interface TTTagView : UIView

@property (nonatomic, weak) id <TTTagViewDelegate> delegate;
/**
 *  此属性是为了KVO监测上边输入框的高度变化
 */
@property (assign, nonatomic) CGFloat changeHeight;
/**
 *  输入框
 */
@property (nonatomic, strong) UITextField *tfInput;
/**
 *  默认是编辑模式(TTTagView_Type_Edit)
 */
@property (nonatomic) TTTagView_Type type;
/**
 *  默认的标签宽度
 */
@property (nonatomic) float tagWidht;
/**
 *  默认的标签高度
 */
@property (nonatomic) float tagHeight;
/**
 *  标签视图的最大高度(超过最大值的话就不会再增大父视图的frame, 只是会往上边滚动)
 */
@property (nonatomic) float viewMaxHeight;
/**
 *  第一个参数是左右两个标签之间的间隔  第二个参数是上下两个标签之间的间隔
 */
@property (nonatomic) CGSize tagPaddingSize;
/**
 *  第一个参数表示标签内部text文本左右距离文本框的距离
 */
@property (nonatomic) CGSize textPaddingSize;
/**
 *  标签字体大小
 */
@property (nonatomic, strong) UIFont* fontTag;
/**
 *  输入标签的字体大小
 */
@property (nonatomic, strong) UIFont* fontInput;
/**
 *  输入标签的背景颜色
 */
@property (nonatomic, strong) UIColor *inputBgColor;
/**
 *  输入标签占位字符的文字颜色
 */
@property (nonatomic, strong) UIColor *inputPlaceHolderTextColor;
/**
 *  输入标签正在输入时的文字颜色
 */
@property (nonatomic, strong) UIColor *inputTextColor;
/**
 *  输入标签的边框颜色
 */
@property (nonatomic, strong) UIColor *inputBorderColor;
/**
 *  未被选中时的标签的背景颜色
 */
@property (nonatomic, strong) UIColor *bgColor;
/**
 *  未被选中时的标签的文字颜色
 */
@property (strong, nonatomic) UIColor *textColor;
/**
 *  未被选中时的标签的边框颜色
 */
@property (nonatomic, strong) UIColor *borderColor;
/**
 *  被选中时的标签的背景颜色
 */
@property (strong, nonatomic) UIColor *selBgColor;
/**
 *  被选中时的标签的文字颜色
 */
@property (nonatomic, strong) UIColor *selTextColor;
/**
 *  被选中时的标签的边框颜色
 */
@property (strong, nonatomic) UIColor *selBorderColor;
/**
 *  要删除的标签
 */
@property (copy, nonatomic) NSString *deleteString;

/**
 *  添加标签
 *
 *  @param tags 要添加的标签数组
 */
- (void)addTags:(NSArray *)tags;
/**
 *  刷新输入视图的布局
 */
- (void)layoutTagviews;

- (NSMutableArray *)tagStrings;

@end
