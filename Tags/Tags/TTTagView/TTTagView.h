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

- (void)deleteBtnClick:(NSString *)string;
- (void)finishInput:(NSString *)string;

@end

/**
 标签的当前状态
 */
typedef enum {
    
    TTTagView_Type_Edit,
    TTTagView_Type_Display,
    TTTagView_Type_Selected
    
} TTTagView_Type;

@interface TTTagView : UIView

@property (nonatomic, strong) id <TTTagViewDelegate> delegate;

@property (assign, nonatomic) CGFloat changeHeight;

@property (nonatomic, strong) UITextField* tfInput;
/**
 *  默认是编辑模式(TTTagView_Type_Edit)
 */
@property (nonatomic) TTTagView_Type type;

@property (nonatomic) float tagWidht;
@property (nonatomic) float tagHeight;

@property (nonatomic) float viewMaxHeight;

@property (nonatomic) CGSize tagPaddingSize;
@property (nonatomic) CGSize textPaddingSize;


@property (nonatomic, strong) UIFont* fontTag;
@property (nonatomic, strong) UIFont* fontInput;


@property (nonatomic, strong) UIColor* colorTag;
@property (nonatomic, strong) UIColor* colorInput;
@property (nonatomic, strong) UIColor* colorInputPlaceholder;

@property (nonatomic, strong) UIColor* colorTagBg;
@property (nonatomic, strong) UIColor* colorInputBg;
@property (nonatomic, strong) UIColor* colorInputBoard;

@property (strong, nonatomic) UIColor *mainColor;


@property (copy, nonatomic) NSString *deleteString;


- (void)addTags:(NSArray *)tags;
- (void)addTags:(NSArray *)tags selectedTags:(NSArray*)selectedTags;
-(void)layoutTagviews;
-(void)setTagStringsSelected:(NSMutableArray *)tagStringsSelected;
-(NSMutableArray *)tagStrings;
@end
