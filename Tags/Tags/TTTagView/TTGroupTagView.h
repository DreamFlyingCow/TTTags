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

- (void)buttonClick:(NSString *)string and:(BOOL)isDelete;

@end


@interface TTGroupTagView : UIView

@property (nonatomic, strong) id <TTGroupTagViewDelegate> delegate;

@property (assign, nonatomic) CGFloat changeHeight;

@property (nonatomic, strong) UITextField* tfInput;

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

@property (copy, nonatomic) NSString *deleteString;


- (void)addTags:(NSArray *)tags;
- (void)addTags:(NSArray *)tags selectedTags:(NSArray*)selectedTags;
-(void)layoutTags;
-(void)setTagStringsSelected:(NSMutableArray *)tagStringsSelected;
-(NSMutableArray *)tagStrings;


@end
