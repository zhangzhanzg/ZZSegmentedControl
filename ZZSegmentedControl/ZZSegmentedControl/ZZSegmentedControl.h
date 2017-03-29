//
//  ZZSegmentedControl.h
//  ZZSegmentedControl
//
//  Created by Angel on 2017/3/27.
//  Copyright © 2017年 Angel. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN CGFloat const kDefaultSegmentedControlHeight;

typedef void(^ClickSegmentedControlBlock)(NSInteger currentIndex);

@interface ZZSegmentedControl : UIView

/**
 *  初始化
 */
- (instancetype)initWithItems:(NSArray <NSString *>*)items;

/**
 *  设置Item颜色，normalColor默认blackColor，seletedColor默认redColor，color必须根据RGB设置;
 */
- (void)setItemNormalColor:(UIColor *)normalColor selectedColor:(UIColor *)selectedColor;

/**
 *  设置当前选中下标， 默认0
 */
- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animted;

/**
 *  设置偏移量
 */
- (void)setContentOffsetX:(CGFloat)offsetX;

/**
 *  点击事件回调
 */
- (void)didClickSegmentedControlBlock:(ClickSegmentedControlBlock)block;

@end
