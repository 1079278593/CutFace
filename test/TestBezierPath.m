//
//  TestBezierPath.m
//  test
//
//  Created by ming on 16/4/6.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "TestBezierPath.h"

@implementation TestBezierPath

- (void)drawRect:(CGRect)rect
{
    UIColor *color = [UIColor redColor];
    [color set]; //设置线条颜色
    
    UIBezierPath* aPath = [UIBezierPath bezierPath];
    
    aPath.lineWidth = 5.0;
    aPath.lineCapStyle = kCGLineCapRound; //线条拐角
    aPath.lineJoinStyle = kCGLineCapRound; //终点处理
    
    [aPath moveToPoint:CGPointMake(0, 40)];
    
    [aPath addQuadCurveToPoint:CGPointMake(60, 40) controlPoint:CGPointMake(30, 60)];
    
//    [aPath stroke];
    [aPath fill];
}

@end
