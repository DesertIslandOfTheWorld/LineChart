//
//  IDLineChartView.h
//  LineChart
//
//  Created by Mac on 16/1/7.
//  Copyright © 2016年 Island. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 折线图上的点 */
@interface IDLineChartPoint : NSObject
/** x轴偏移量 */
@property (nonatomic, assign) float x;
/** y轴偏移量 */
@property (nonatomic, assign) float y;
/** 工厂方法 */
+ (instancetype)pointWithX:(float)x andY:(float)y;
@end

/** 折线图视图 */
@interface IDLineChartView : UIView
/** 折线转折点数组 */
@property (nonatomic, strong) NSMutableArray<IDLineChartPoint *> *pointArray;
/** 开始绘制折线图 */
- (void)startDrawlineChart;
@end
