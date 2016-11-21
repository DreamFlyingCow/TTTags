//
//  ViewController.m
//  Tags
//
//  Created by 赵春浩 on 16/8/15.
//  Copyright © 2016年 Mr Zhao. All rights reserved.
//

#import "ViewController.h"
#import "TTTagView.h"
#import "TTGroupTagView.h"

@interface ViewController ()<TTTagViewDelegate, TTGroupTagViewDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

/**
 *  记录输入标签的高度
 */
@property (assign, nonatomic) CGFloat inputHeight;
/**
 *  输入标签的背景视图(为了改变其高度)
 */
@property (strong, nonatomic) UIView *textBgView;
/**
 *  用来展示标签列表的
 */
@property (strong, nonatomic) UITableView *tableView;
/**
 *  存储获取的标签列表
 */
@property (strong, nonatomic) NSMutableArray *dataArr;

/**
 *  存储标签列表cell的高度
 */
@property (strong, nonatomic) NSMutableArray *heightArr;
/**
 *  记录输入框中输入的标签
 */
@property (strong, nonatomic) NSMutableArray *selectedTags;

@end

@implementation ViewController {
    /**
     *  输入标签view
     */
    TTTagView *inputTagView;
    
}

#pragma mark - 懒加载数据
- (UIView *)textBgView {
    if (_textBgView == nil) {
        _textBgView = [[UIView alloc] init];
    }
    return _textBgView;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.inputHeight, kScreenWidth , kScreenHeight - (64 + self.inputHeight)) style:UITableViewStyleGrouped];
    }
    return _tableView;
}

- (NSMutableArray *)dataArr {
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (NSMutableArray *)heightArr {
    if (_heightArr == nil) {
        _heightArr = [NSMutableArray array];
    }
    return _heightArr;
}

- (NSMutableArray *)selectedTags {
    if (_selectedTags == nil) {
        _selectedTags = [NSMutableArray array];
    }
    return _selectedTags;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.inputHeight = 50;
    self.view.backgroundColor = kCOLOR(245);
    [self addSubviews];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self setData];
    
    //设置视图是否延伸到StatusBar的后面
    if (kCurrentFloatDevice >= 7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        //刷新状态栏样式
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    if (self.bqlabStr.length > 0) {
        [inputTagView addTags:self.selectedTags];
    }
    
    [self addNavBarRightButton];
    
    
}

#pragma mark - 添加一个导航栏右侧的确定按钮
- (void)addNavBarRightButton {
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    [btn setTitleColor:kRandomColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(didFinishBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

#pragma mark - 确定按钮的点击事件
- (void)didFinishBtnClick:(UIButton *)btn {
    
    NSString *tags = [self.selectedTags componentsJoinedByString:@" "];
    if ([self.delegate respondsToSelector:@selector(updateTagsLabelWithTagsString:)]) {
        [self.delegate updateTagsLabelWithTagsString:tags];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - 获取顾客标签的列表
- (void)setData {
    
    self.dataArr = [NSMutableArray arrayWithArray:@[@[@"1", @"22", @"哈哈", @"我是标签", @"我也可以换行"], @[@"333", @"4444"], @[@"55555", @"666666"], @[@"11", @"222"], @[@"3333", @"44444"], @[@"555555", @"6666666"], @[@"111", @"2222"], @[@"33333", @"444444"], @[@"5555555", @"66666666"]]];
    [self.tableView reloadData];
}

#pragma mark - 加载子视图
- (void)addSubviews {
    
    UIView *textBgView = [[UIView alloc] init];
    textBgView.layer.borderColor = kCOLOR(220) .CGColor;
    textBgView.layer.borderWidth = 0.5;
    
    [self.view addSubview:textBgView];
    self.textBgView = textBgView;
    textBgView.frame = CGRectMake(0, 0, kScreenWidth, self.inputHeight);
    
    inputTagView = [[TTTagView alloc] initWithFrame:CGRectMake(0, 0,self.view.width ,self.inputHeight)];
    inputTagView.translatesAutoresizingMaskIntoConstraints=YES;
    inputTagView.delegate = self;
    
    {// 这些属性有默认值, 可以不进行设置
        inputTagView.inputBgColor = kRandomColor;
        inputTagView.inputPlaceHolderTextColor = kRandomColor;
        inputTagView.inputTextColor = kRandomColor;
        inputTagView.inputBorderColor = kRandomColor;
        inputTagView.bgColor = kRandomColor;
        inputTagView.textColor = kRandomColor;
        inputTagView.borderColor = kRandomColor;
        inputTagView.selBgColor = kRandomColor;
        inputTagView.selTextColor = kRandomColor;
        inputTagView.selBorderColor = kRandomColor;
    }
    
    // KVO监测其高度是否发生改变(改变的话就需要修改下边的所有控件的frame)
    [inputTagView addObserver:self forKeyPath:@"changeHeight" options:NSKeyValueObservingOptionNew context:nil];
    
    [textBgView addSubview:inputTagView];
    
    // 这里刷新是为了如果没有已经存在的标签(bqlabStr)传进来的话就会出问题
    [inputTagView layoutTagviews];
    [inputTagView resignFirstResponder];
    
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = kCOLOR(245);
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = kCOLOR(245);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSelectedTag)];
    [cell.contentView addGestureRecognizer:tap];
    [cell.contentView addSubview:[self addHistoryViewTagsWithCGRect:CGRectMake(0, 0, kScreenWidth, 44) andIndex:indexPath]];
    
    return cell;
    
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.heightArr.count > 0) {
        return [self.heightArr[indexPath.section] floatValue];
        
    } else {
        return 44.0;
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.01;
}

#pragma mark - 返回组标题
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    bgView.backgroundColor = kCOLOR(245);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 12.5, 15, 15)];
    view.backgroundColor = [self getGroupTitleColorWithIndex:section];
    view.layer.cornerRadius = 2;
    [bgView addSubview:view];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(35, 10, kScreenWidth - 35, 20)];
    if (self.dataArr.count > 0) {
        label.text = @"此处应该有标题";
    }
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentLeft;
    [bgView addSubview:label];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSelectedTag)];
    
    [bgView addGestureRecognizer:tap];
    
    return bgView;
    
}

- (UIColor *)getGroupTitleColorWithIndex:(NSInteger)section {
    
    NSInteger index = section % 4;
    
    switch (index) {
        case 0:
            return kCustomColor(255, 102, 102);
            break;
            
        case 1:
            return kCustomColor(153, 153, 255);
            break;
        case 2:
            return kCustomColor(51, 204, 153);
            break;
            
        default:
            return kCustomColor(255, 153, 0);
            break;
    }
    
}


#pragma mark - 添加标签列表视图
- (TTGroupTagView *)addHistoryViewTagsWithCGRect:(CGRect)rect andIndex:(NSIndexPath *)indexPath{
    
    
    TTGroupTagView *tagView = [[TTGroupTagView alloc] initWithFrame:rect];
    tagView.tag = indexPath.section + 1000;
    tagView.translatesAutoresizingMaskIntoConstraints = YES;
    tagView.delegate = self;
    tagView.changeHeight = 0;
    tagView.backgroundColor = [UIColor clearColor];

    {// 这些属性颜色有默认值, 可以设置也可以不设置
        tagView.bgColor = kRandomColor;
        tagView.textColor = kRandomColor;
        tagView.borderColor = kRandomColor;
        tagView.selBgColor = kRandomColor;
        tagView.selTextColor = kRandomColor;
        tagView.selBorderColor = kRandomColor;
        
    }
    
    if (self.dataArr.count > 0) {
        [tagView addTags:self.dataArr[indexPath.section]];
    }
    // 这里存储tagView的最大高度, 是为了设置cell的行高
    [self.heightArr addObject:[NSString stringWithFormat:@"%f", tagView.changeHeight]];
    
    
    // 在这里处理上下标签的对应关系, 上边出现的标签如果下边也有的话就要修改其状态(改为选中状态)
    {
        
        if (self.selectedTags.count != 0) {
            NSArray *tags = self.selectedTags;
            [inputTagView addTags:tags];
            NSMutableArray *arr = [NSMutableArray array];
            for (int i = 0; i < tags.count; i ++) {
                
                NSArray *result = [tagView.tagStrings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == %@", tags[i]]];
                
                if (result.count != 0) {
                    [arr addObject:tags[i]];
                    
                }
                
            }
            [tagView setTagStringsSelected:arr];
            
        }
        
    }
    
    return tagView;
    
}

#pragma mark - TTGroupTagViewDelegate
// 点击下边的固定标签列表, 对应上边的标签是删除还是添加(通过这个代理方法实现)
- (void)buttonClick:(NSString *)string and:(BOOL)isDelete {
    
    [inputTagView endEditing:YES];
    if (isDelete) {// 删除
        
        [self.selectedTags removeObject:string];
        inputTagView.deleteString = string;
    } else {// 添加
        
        [inputTagView addTags:@[string]];
    }
}

#pragma mark - TTTagViewDelegate
// 点击上边的输入标签并且删除之后,看下边是否有对应的标签, 有的话就修改其状态
- (void)deleteBtnClick:(NSString *)string {
    
    [self.selectedTags removeObject:string];
    // 遍历下边的固定标签, 看是否有相同的
    for (int j = 0; j < self.dataArr.count; j ++) {
        NSArray *lists = self.dataArr[j];
        NSArray *result = [lists filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == %@", string]];
        
        if (result.count != 0) {
            // 获取到对应的分组标签, 改变其标签的状态
            TTGroupTagView *tagView = [self.view viewWithTag:j + 1000];
            tagView.deleteString = string;
            return;
        }
    }
    
}

#pragma mark - 上边的输入标签, 输入完成之后, 遍历下边的固定标签, 看是否有相同的, 如果有相同的, 就修改其状态(这里也包括刚进入这个页面的时候从上个页面传进来的标签)
- (void)finishInput:(NSString *)string {
    
    self.selectedTags = [inputTagView.tagStrings mutableCopy];
    NSMutableArray *arr = [NSMutableArray array];
    
    for (int j = 0; j < self.dataArr.count; j ++) {
        NSArray *lists = self.dataArr[j];
        NSArray *result = [lists filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == %@", string]];
        
        if (result.count != 0) {
            [arr addObject:string];
            TTGroupTagView *tagView = [self.view viewWithTag:j + 1000];
            // 修改对应标签的状态为选中状态
            [tagView setTagStringsSelected:arr];
            
            return;
        }
    }
}


#pragma mark - 当被观察的值发生变化，上面那个添加的观察就会生效，而生效后下一步做什么，由下面这个方法决定，下面会输出变化值，即change
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    self.inputHeight = [[change valueForKey:@"new"] floatValue];
    [UIView animateWithDuration:0.25 animations:^{
        self.textBgView.frame = CGRectMake(0, 0, kScreenWidth, self.inputHeight);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.tableView.frame = CGRectMake(0, self.inputHeight, kScreenWidth, kScreenHeight - self.inputHeight - 64);
    }];
    
}

#pragma mark - 添加的手势方法(用来取消inputView中的被选中的标签)
- (void)cancelSelectedTag {
    
    [inputTagView layoutTagviews];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [inputTagView layoutTagviews];
    [inputTagView endEditing:YES];
}


#pragma mark - set方法
- (void)setBqlabStr:(NSString *)bqlabStr {
    if (_bqlabStr != bqlabStr) {
        _bqlabStr = bqlabStr;
    }
    if (bqlabStr.length > 0) {
        NSArray *tags = [self.bqlabStr componentsSeparatedByString:@" "];
        self.selectedTags = [NSMutableArray arrayWithArray:tags];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEditing) name:@"willEditing" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endEditing) name:@"endEditing" object:nil];
    
    
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"willEditing" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"endEditing" object:nil];
    
    [inputTagView removeObserver:self forKeyPath:@"changeHeight"];
}

#pragma mark - 这里是通知传过来的方法
// 这个是textField将要编辑的时候调用
- (void)willEditing {
    
    NSLog(@"willEditing");
    
}

// 这个是textField结束编辑的时候调用
- (void)endEditing {
    
    NSLog(@"endEditing");
    
}

- (void)dealloc {
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
