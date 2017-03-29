//
//  ViewController.m
//  ZZSegmentedControl
//
//  Created by Angel on 2017/3/27.
//  Copyright © 2017年 Angel. All rights reserved.
//

#import "ViewController.h"
#import "ZZSegmentedControl.h"

@interface ViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) ZZSegmentedControl *segmentedControl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSArray *titleArray = @[@"头条", @"要闻", @"科技", @"北京", @"轻松一刻", @"独家", @"社会", @"历史", @"航空"];
    self.segmentedControl = [[ZZSegmentedControl alloc] initWithItems:titleArray];
    _segmentedControl.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 40);
    [self.view addSubview:_segmentedControl];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 150)];
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor cyanColor];
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame) * titleArray.count, 150);
    [self.view addSubview:scrollView];
    scrollView.center = self.view.center;
    scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.view.frame) * 3, 0);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    [_segmentedControl setContentOffsetX:offsetX];
}


@end
