//
//  ZZSegmentedControl.m
//  ZZSegmentedControl
//
//  Created by Angel on 2017/3/27.
//  Copyright © 2017年 Angel. All rights reserved.
//

#import "ZZSegmentedControl.h"

#define  ZZScreenWidth [[UIScreen mainScreen] bounds].size.width

CGFloat const kDefaultSegmentedControlHeight = 40;
static CGFloat const kDefaultItemTag = 12345;           // Item tag基数
static CGFloat const kItemDistance = 20;                // 默认item间距
static CGFloat const kDefaultScaleValue = 0.2;          // 默认缩放比例

@interface ZZSegmentedControl ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *dataArray;        // Titles
@property (nonatomic, strong) NSMutableArray *widthArray;       // item宽度数组
@property (nonatomic, assign) NSInteger currentIndex;           // 当前下班
@property (nonatomic, copy) ClickSegmentedControlBlock block;   // 回调

@property (nonatomic, strong) NSArray *middleColorRgbArray;     // 颜色差值
@property (nonatomic, strong) NSArray *selectedColorRgbArray;   // 选中颜色RGB
@property (nonatomic, strong) NSArray *normalColorRgbArray;     // 正常颜色RGB
@property (nonatomic, strong) UIColor *normalColor;     // 未选中颜色
@property (nonatomic, strong) UIColor *selectedColor;   // 选中颜色

@end

@implementation ZZSegmentedControl

#pragma mark - init

- (instancetype)initWithItems:(NSArray <NSString *>*)items {
    self = [super init];
    if (self) {
        [self creatScrollView];
        
        [self.dataArray addObjectsFromArray:items];
        [self configSegmentedControl];
        self.currentIndex = 0;
        [self setSelectedIndex:0 animated:NO];
    }
    return self;
}

- (void)creatScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ZZScreenWidth, 40)];
    _scrollView.backgroundColor = [UIColor cyanColor];
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];
}

- (void)configSegmentedControl {
    if (self.dataArray.count <= 0) {
        return;
    }
    NSInteger dataCount = self.dataArray.count;
    
    CGFloat totalWidth = kItemDistance;
    
    for (NSInteger i = 0; i < dataCount; i++) {
        NSString *itemTitle = self.dataArray[i];
        CGFloat itemWidth = [self getItemWidthWithItemTitle:itemTitle];
        
        UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [titleButton setTitle:itemTitle forState:UIControlStateNormal];
        titleButton.tag = kDefaultItemTag + i;
        titleButton.titleLabel.font = [UIFont systemFontOfSize:16];
        titleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        titleButton.frame = CGRectMake(totalWidth, 0, itemWidth, 40);
        [titleButton setTitleColor:self.normalColor forState:UIControlStateNormal];
        [titleButton addTarget:self action:@selector(clickItemButton:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:titleButton];
        
        [self.widthArray addObject:@(itemWidth)];
        totalWidth += (itemWidth + kItemDistance);
    }
    
    _scrollView.contentSize = CGSizeMake(totalWidth, 40);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self resetButtonTitelColor];
}

- (void)clickItemButton:(UIButton *)button {
    NSInteger index = button.tag - kDefaultItemTag;
    if (self.block) {
        self.block(index);
    }
    [self setSelectedIndex:index animated:YES];
}

#pragma mark - public method

- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animted {
    BOOL isLegal = index >= 0;
    if (!isLegal) {
        return;
    }
    UIButton *currentItem = (UIButton *)[_scrollView viewWithTag:(kDefaultItemTag + index)];
    UIButton *lastItem = (UIButton *)[_scrollView viewWithTag:(kDefaultItemTag + self.currentIndex)];
    [lastItem setTitleColor:self.normalColor forState:UIControlStateNormal];
    [currentItem setTitleColor:self.selectedColor forState:UIControlStateNormal];
    if (animted) {
        [UIView animateWithDuration:0.25 animations:^{
            lastItem.transform = CGAffineTransformMakeScale(1.0, 1.0);
            currentItem.transform = CGAffineTransformMakeScale(1.2, 1.2);
        }];
    } else {
        lastItem.transform = CGAffineTransformMakeScale(1.0, 1.0);
        currentItem.transform = CGAffineTransformMakeScale(1.2, 1.2);
    }
    self.currentIndex = index;
    [self moveButtonToCenterWithIndex:index animated:animted];
}

- (void)moveButtonToCenterWithIndex:(NSInteger)index animated:(BOOL)animted {
    UIButton *button = (UIButton *)[_scrollView viewWithTag:(kDefaultItemTag + index)];
    CGRect buttonFrame = button.frame;
    CGRect buttonConvertFrame = [_scrollView convertRect:buttonFrame toView:self];
    CGFloat halfButtonWidth = buttonFrame.size.width / 2.0;
    CGFloat halfScreenWidth = ZZScreenWidth / 2.0;
    CGFloat convertOriginX = buttonConvertFrame.origin.x;
    CGFloat buttonHeight = buttonFrame.size.height;
    
    if (convertOriginX + halfButtonWidth <= halfScreenWidth) {
        CGRect rect = [self convertRect:CGRectMake(-(halfScreenWidth - (convertOriginX + halfButtonWidth)), 0, (halfScreenWidth - (convertOriginX + halfButtonWidth)), buttonHeight) toView:_scrollView];
        buttonFrame = rect;
    } else if (convertOriginX + halfButtonWidth > halfScreenWidth) {
        CGRect rect = [self convertRect:CGRectMake(ZZScreenWidth, 0, (convertOriginX + halfButtonWidth - halfScreenWidth), buttonHeight) toView:_scrollView];
        buttonFrame = rect;
    }
    
    [_scrollView scrollRectToVisible:buttonFrame animated:animted];
}

- (void)setContentOffsetX:(CGFloat)offsetX {
    NSInteger tempIndex = offsetX / ZZScreenWidth;
    CGFloat percent = offsetX / ZZScreenWidth - tempIndex;
    if (percent == 0) {
        [self setSelectedIndex:tempIndex animated:YES];
    }
    UIButton *lastButton = (UIButton *)[_scrollView viewWithTag:kDefaultItemTag + tempIndex];
    UIButton *currentButton = (UIButton *)[_scrollView viewWithTag:kDefaultItemTag + tempIndex + 1];
    CGFloat scaleValue1 = 1 + kDefaultScaleValue * (1 - percent);
    CGFloat scaleValue2 = 1 + kDefaultScaleValue * percent;
    lastButton.transform = CGAffineTransformMakeScale(scaleValue1, scaleValue1);
    currentButton.transform = CGAffineTransformMakeScale(scaleValue2, scaleValue2);
    
    [lastButton setTitleColor:[self getItemGradientColorWithPersent:percent willSelected:NO] forState:UIControlStateNormal];
    
    [currentButton setTitleColor:[self getItemGradientColorWithPersent:percent willSelected:YES] forState:UIControlStateNormal];
}

- (void)didClickSegmentedControlBlock:(ClickSegmentedControlBlock)block {
    if (!block) {
        return;
    }
    self.block = nil;
    self.block = block;
}

- (void)setItemNormalColor:(UIColor *)normalColor selectedColor:(UIColor *)selectedColor {
    if (normalColor) {
        self.normalColor = normalColor;
        self.normalColorRgbArray = [self getColorRgbArrayWithColor:normalColor];
    }
    if (selectedColor) {
        self.selectedColor = selectedColor;
        self.selectedColorRgbArray = [self getColorRgbArrayWithColor:selectedColor];
    }
    _middleColorRgbArray = [self getMiddleColorRgbWithNormalColorArr:self.normalColorRgbArray selectedColorArr:self.selectedColorRgbArray];
}

#pragma mark - private method

- (void)resetButtonTitelColor {
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            [obj setTitleColor:self.normalColor forState:UIControlStateNormal];
        }
    }];
    UIButton *selectedButton = (UIButton *)[self.scrollView viewWithTag:self.currentIndex + kDefaultItemTag];
    [selectedButton setTitleColor:self.selectedColor forState:UIControlStateNormal];
}

- (CGFloat)getItemWidthWithItemTitle:(NSString *)title {
    BOOL isLegal = title && title.length > 0;
    if (!isLegal) {
        return 0;
    }
    CGFloat extraWidth = 4.0;
    CGSize textSize = [title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    return ceilf(extraWidth + textSize.width);
}

- (UIColor *)getItemGradientColorWithPersent:(CGFloat)percent willSelected:(BOOL)willSelected {
    if (willSelected) {
        return [UIColor colorWithRed:[self.normalColorRgbArray[0] floatValue] - [self.middleColorRgbArray[0] floatValue] * percent green:[self.normalColorRgbArray[1] floatValue] - [self.middleColorRgbArray[1] floatValue] * percent blue:[self.normalColorRgbArray[2] floatValue] - [self.middleColorRgbArray[2] floatValue] * percent alpha:1.0];
    }
    return [UIColor colorWithRed:[self.selectedColorRgbArray[0] floatValue] + [self.middleColorRgbArray[0] floatValue] * percent green:[self.selectedColorRgbArray[1] floatValue] + [self.middleColorRgbArray[1] floatValue] * percent blue:[self.selectedColorRgbArray[2] floatValue] + [self.middleColorRgbArray[2] floatValue] * percent alpha:1.0];
}

- (NSArray *)getMiddleColorRgbWithNormalColorArr:(NSArray *)normalArr selectedColorArr:(NSArray *)selectedArr {
    NSArray *tempArray;
    if (normalArr && selectedArr) {
        CGFloat r = [normalArr[0] floatValue] - [selectedArr[0] floatValue];
        CGFloat g = [normalArr[1] floatValue] - [selectedArr[1] floatValue];
        CGFloat b = [normalArr[2] floatValue] - [selectedArr[2] floatValue];
        tempArray = [NSArray arrayWithObjects:@(r), @(g), @(b), nil];
        return tempArray;
    }
    return nil;
}

- (NSArray *)getColorRgbArrayWithColor:(UIColor *)color {
    CGFloat numOfcomponents = CGColorGetNumberOfComponents(color.CGColor);
    if (numOfcomponents == 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        return [NSArray arrayWithObjects:@(components[0]), @(components[1]), @(components[2]), nil];
    }
    NSAssert(numOfcomponents != 4, @"颜色设置错误");
    return nil;
}


#pragma mark - setter and getter

- (UIColor *)normalColor {
    if (!_normalColor) {
        _normalColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:1.];
    }
    return _normalColor;
}

- (UIColor *)selectedColor {
    if (!_selectedColor) {
        _selectedColor = [UIColor colorWithRed:1. green:0. blue:0. alpha:1.];
    }
    return _selectedColor;
}

- (NSArray *)middleColorRgbArray {
    if (!_middleColorRgbArray) {
        _middleColorRgbArray = [self getMiddleColorRgbWithNormalColorArr:self.normalColorRgbArray selectedColorArr:self.selectedColorRgbArray];
    }
    return _middleColorRgbArray;
}

- (NSArray *)normalColorRgbArray {
    if (!_normalColorRgbArray) {
        _normalColorRgbArray = [self getColorRgbArrayWithColor:self.normalColor];
    }
    return  _normalColorRgbArray;
}

- (NSArray *)selectedColorRgbArray {
    if (!_selectedColorRgbArray) {
        _selectedColorRgbArray = [self getColorRgbArrayWithColor:self.selectedColor];
    }
    return  _selectedColorRgbArray;
}


- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)widthArray {
    if (!_widthArray) {
        self.widthArray = [NSMutableArray array];
    }
    return _widthArray;
}

@end
