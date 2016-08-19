//
//  ViewController.m
//  LineChart
//
//  Created by Mac on 16/1/7.
//  Copyright © 2016年 Island. All rights reserved.
//

#import "ViewController.h"
#import "IDLineChartView.h"

@interface ViewController ()

/** 折线图 */
@property (nonatomic, strong) IDLineChartView *lineCharView;
/** 开始绘制折线图按钮 */
@property (nonatomic, strong) UIButton *drawLineChartButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建折线图视图
    self.lineCharView = [[IDLineChartView alloc] initWithFrame:CGRectMake(35, 164, 340, 170)];
    [self.view addSubview:self.lineCharView];
    
    self.drawLineChartButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.drawLineChartButton.frame = CGRectMake(180, 375, 50, 44);
    [self.drawLineChartButton setTitle:@"开始" forState:UIControlStateNormal];
    [self.drawLineChartButton addTarget:self action:@selector(drawLineChart) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.drawLineChartButton];
}

// 开始绘制折线图
- (void)drawLineChart {
    [self.lineCharView startDrawlineChart];
}

@end
