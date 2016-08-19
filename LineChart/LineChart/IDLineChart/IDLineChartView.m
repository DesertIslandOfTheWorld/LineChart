//
//  IDLineChartView.m
//  LineChart
//
//  Created by Mac on 16/1/7.
//  Copyright © 2016年 Island. All rights reserved.
//

#import "IDLineChartView.h"

/** 折线图上的点 */
@implementation IDLineChartPoint
+ (instancetype)pointWithX:(float)x andY:(float)y {
    IDLineChartPoint *point = [[self alloc] init];
    point.x = x;
    point.y = y;
    return point;
}
@end

// 与坐标轴相关的常量
/** 坐标轴信息区域宽度 */
static const CGFloat kPadding = 25.0;
/** 坐标系中横线的宽度 */
static const CGFloat kCoordinateLineWith = 1.0;
@interface IDLineChartView ()
/** X轴的单位长度 */
@property (nonatomic, assign) CGFloat xAxisSpacing;
/** Y轴的单位长度 */
@property (nonatomic, assign) CGFloat yAxisSpacing;
/** X轴的信息 */
@property (nonatomic, strong) NSMutableArray<NSString *> *xAxisInformationArray;
/** Y轴的信息 */
@property (nonatomic, strong) NSMutableArray<NSString *> *yAxisInformationArray;
/** 渐变背景视图 */
@property (nonatomic, strong) UIView *gradientBackgroundView;
/** 渐变图层 */
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
/** 颜色数组 */
@property (nonatomic, strong) NSMutableArray *gradientLayerColors;
/** 折线图层 */
@property (nonatomic, strong) CAShapeLayer *lineChartLayer;
/** 折线图终点处的标签 */
@property (nonatomic, strong) UIButton *tapButton;
@end

@implementation IDLineChartView

- (CGFloat)xAxisSpacing {
    if (_xAxisSpacing == 0) {
        _xAxisSpacing = (self.bounds.size.width - kPadding) / (float)self.xAxisInformationArray.count;
    }
    return _xAxisSpacing;
}
- (CGFloat)yAxisSpacing {
    if (_yAxisSpacing == 0) {
        _yAxisSpacing = (self.bounds.size.height - kPadding) / (float)self.yAxisInformationArray.count;
    }
    return _yAxisSpacing;
}
- (NSMutableArray<NSString *> *)xAxisInformationArray {
    if (_xAxisInformationArray == nil) {
        // 创建可变数组
        _xAxisInformationArray = [[NSMutableArray alloc] init];
        // 当前日期和日历
        NSDate *today = [NSDate date];
        NSCalendar *currentCalendar = [NSCalendar currentCalendar];
        // 设置日期格式
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM-dd";
        // 获取最近一周的日期
        NSDateComponents *components = [[NSDateComponents alloc] init];
        for (int i = -7; i<0; i++) {
            components.day = i;
            NSDate *dayOfLatestWeek = [currentCalendar dateByAddingComponents:components toDate:today options:0];
            NSString *dateString = [dateFormatter stringFromDate:dayOfLatestWeek];
            [_xAxisInformationArray addObject:dateString];
        }
    }
    return _xAxisInformationArray;
}
- (NSMutableArray<NSString *> *)yAxisInformationArray {
    if (_yAxisInformationArray == nil) {
        _yAxisInformationArray = [NSMutableArray arrayWithObjects:@"0", @"10", @"20", @"30", @"40", @"50", nil];
    }
    return _yAxisInformationArray;
}

// 折线图上的点（重写get方法，后期需要暴露接口）
- (NSMutableArray<IDLineChartPoint *> *)pointArray {
    if (_pointArray == nil) {
        _pointArray = [NSMutableArray arrayWithObjects:[IDLineChartPoint pointWithX:1 andY:1], [IDLineChartPoint pointWithX:2 andY:2], [IDLineChartPoint pointWithX:3 andY:1.5], [IDLineChartPoint pointWithX:4 andY:2], [IDLineChartPoint pointWithX:5 andY:4], [IDLineChartPoint pointWithX:6 andY:1], [IDLineChartPoint pointWithX:7 andY:2], nil];
    }
    return _pointArray;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // 设置折线图的背景色
        self.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1.0];
        
        /** 设置渐变背景视图 */
        [self drawGradientBackgroundView];
        /** 设置折线图层 */
        [self setupLineChartLayerAppearance];
    }
    
    return self;
}

/** 绘制渐变背景色 */
- (void)drawGradientBackgroundView {
    // 渐变背景视图（不包含坐标轴）
    self.gradientBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(kPadding, 0, self.bounds.size.width - kPadding, self.bounds.size.height - kPadding)];
    [self addSubview:self.gradientBackgroundView];
    // 创建并设置渐变背景图层
    //初始化CAGradientlayer对象，使它的大小为渐变背景视图的大小
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = self.gradientBackgroundView.bounds;
    //设置渐变区域的起始和终止位置（范围为0-1），即渐变路径
    self.gradientLayer.startPoint = CGPointMake(0, 0.0);
    self.gradientLayer.endPoint = CGPointMake(1.0, 0.0);
    //设置颜色的渐变过程
    self.gradientLayerColors = [NSMutableArray arrayWithArray:@[(__bridge id)[UIColor colorWithRed:253 / 255.0 green:164 / 255.0 blue:8 / 255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:251 / 255.0 green:37 / 255.0 blue:45 / 255.0 alpha:1.0].CGColor]];
    self.gradientLayer.colors = self.gradientLayerColors;
    //将CAGradientlayer对象添加在我们要设置背景色的视图的layer层
    [self.gradientBackgroundView.layer addSublayer:self.gradientLayer];
}

/** 设置折线图层 */
- (void)setupLineChartLayerAppearance {
    /** 折线路径 */
    UIBezierPath *path = [UIBezierPath bezierPath];
    [self.pointArray enumerateObjectsUsingBlock:^(IDLineChartPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 折线
        if (idx == 0) {
            [path moveToPoint:CGPointMake(self.xAxisSpacing * 0.5 + (obj.x - 1) * self.xAxisSpacing, self.bounds.size.height - kPadding - obj.y * self.yAxisSpacing)];
        } else {
            [path addLineToPoint:CGPointMake(self.xAxisSpacing * 0.5 + (obj.x - 1) * self.xAxisSpacing, self.bounds.size.height - kPadding - obj.y * self.yAxisSpacing)];
        }
        // 折线起点和终点位置的圆点
        if (idx == 0 || idx == self.pointArray.count - 1) {
            [path addArcWithCenter:CGPointMake(self.xAxisSpacing * 0.5 + (obj.x - 1) * self.xAxisSpacing, self.bounds.size.height - kPadding - obj.y * self.yAxisSpacing) radius:2.0 startAngle:0 endAngle:2 * M_PI clockwise:YES];
        }
    }];
    /** 将折线添加到折线图层上，并设置相关的属性 */
    self.lineChartLayer = [CAShapeLayer layer];
    self.lineChartLayer.path = path.CGPath;
    self.lineChartLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.lineChartLayer.fillColor = [[UIColor clearColor] CGColor];
    // 默认设置路径宽度为0，使其在起始状态下不显示
    self.lineChartLayer.lineWidth = 4;
    self.lineChartLayer.lineCap = kCALineCapRound;
    self.lineChartLayer.lineJoin = kCALineJoinRound;
    // 设置折线图层为渐变图层的mask
    self.gradientBackgroundView.layer.mask = self.lineChartLayer;
}

/** 动画开始，绘制折线图 */
- (void)startDrawlineChart {
    // 设置路径宽度为4，使其能够显示出来
    self.lineChartLayer.lineWidth = 4;
    // 移除标签，
    if ([self.subviews containsObject:self.tapButton]) {
        [self.tapButton removeFromSuperview];
    }
    // 设置动画的相关属性
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 2.5;
    pathAnimation.repeatCount = 1;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    // 设置动画代理，动画结束时添加一个标签，显示折线终点的信息
    pathAnimation.delegate = self;
    [self.lineChartLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
}

/** 动画结束时，添加一个标签 */
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.tapButton == nil) { // 首次添加标签（避免多次创建和计算）
        CGRect tapButtonFrame = CGRectMake(self.xAxisSpacing * 0.5 + ([self.pointArray[self.pointArray.count - 1] x] - 1) * self.xAxisSpacing + 8, self.bounds.size.height - kPadding - [self.pointArray[self.pointArray.count - 1] y] * self.yAxisSpacing - 34, 30, 30);
        
        self.tapButton = [[UIButton alloc] initWithFrame:tapButtonFrame];
        self.tapButton.enabled = NO;
        [self.tapButton setBackgroundImage:[UIImage imageNamed:@"bubble"] forState:UIControlStateDisabled];
        [self.tapButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [self.tapButton setTitle:@"20" forState:UIControlStateDisabled];
    }
    [self addSubview:self.tapButton];
}

/** 绘制坐标轴 */
- (void)drawRect:(CGRect)rect {
    // 获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // x轴信息
    [self.xAxisInformationArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 计算文字尺寸
        UIFont *informationFont = [UIFont systemFontOfSize:10];
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        attributes[NSForegroundColorAttributeName] = [UIColor colorWithRed:158/255.0 green:158/255.0 blue:158/255.0 alpha:1.0];
        attributes[NSFontAttributeName] = informationFont;
        CGSize informationSize = [obj sizeWithAttributes:attributes];
        // 计算绘制起点
        float drawStartPointX = kPadding + idx * self.xAxisSpacing + (self.xAxisSpacing - informationSize.width) * 0.5;
        float drawStartPointY = self.bounds.size.height - kPadding + (kPadding - informationSize.height) / 2.0;
        CGPoint drawStartPoint = CGPointMake(drawStartPointX, drawStartPointY);
        // 绘制文字信息
        [obj drawAtPoint:drawStartPoint withAttributes:attributes];
    }];
    
    // y轴
    [self.yAxisInformationArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 计算文字尺寸
        UIFont *informationFont = [UIFont systemFontOfSize:10];
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        attributes[NSForegroundColorAttributeName] = [UIColor colorWithRed:158/255.0 green:158/255.0 blue:158/255.0 alpha:1.0];
        attributes[NSFontAttributeName] = informationFont;
        CGSize informationSize = [obj sizeWithAttributes:attributes];
        // 计算绘制起点
        float drawStartPointX = (kPadding - informationSize.width) / 2.0;
        float drawStartPointY = self.bounds.size.height - kPadding - idx * self.yAxisSpacing - informationSize.height * 0.5;
        CGPoint drawStartPoint = CGPointMake(drawStartPointX, drawStartPointY);
        // 绘制文字信息
        [obj drawAtPoint:drawStartPoint withAttributes:attributes];
        // 横向标线
        CGContextSetRGBStrokeColor(context, 231 / 255.0, 231 / 255.0, 231 / 255.0, 1.0);
        CGContextSetLineWidth(context, kCoordinateLineWith);
        CGContextMoveToPoint(context, kPadding, self.bounds.size.height - kPadding - idx * self.yAxisSpacing);
        CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height - kPadding - idx * self.yAxisSpacing);
        CGContextStrokePath(context);
    }];
}
@end
