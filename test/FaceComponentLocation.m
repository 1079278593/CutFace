//
//  FaceComponentLocation.m
//  test
//
//  Created by ming on 16/4/9.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "FaceComponentLocation.h"

@implementation FaceComponentLocation

-(void)convertCoordinate:(CIFaceFeature *)feature photoSize:(CGSize)size{
    
    //1.保存原始信息
    self.faceFeature = feature;
    self.photoSize = size;
    
    
    //2.转换坐标
    
    //2.1 转换人脸坐标
    [self convertFace];
    
    
    //2.2 转换眼球中心
    [self convertEyeball];
    
    
    //2.3.1 转换:眉毛以下的眼睛frame
//    [self convertEye];
    //2.3.2 转换:眉毛以及眼睛frame
    [self convertEyeAndEyebrow];
    
    //2.4 转换嘴巴
    [self convertMouth];
    
    
    //3.1 眼睛的path
    [self setEyesPath];
    
    //3.2 鼻子和嘴巴的path
    [self setNoseAndMouthPath];
    
    //3.3 眉毛以下的脸
    [self setFacePath];
    
    //3.4 专门的脸
    [self setStandardFaceFrame];
}

-(void)convertFace{
    
    CGRect tempRect = CGRectZero;
    
    //转换人脸
    tempRect = self.faceFeature.bounds;
    tempRect.origin.y = self.photoSize.height - tempRect.origin.y - tempRect.size.height;
    self.faceBounds = tempRect;
    
}

-(void)convertEyeball{
    
    CGPoint tempPoint = CGPointZero;
    
    tempPoint = self.faceFeature.leftEyePosition;
    tempPoint.y = self.photoSize.height - tempPoint.y;
    self.leftEyeballCenter = tempPoint;//左眼球
    
    tempPoint = self.faceFeature.rightEyePosition;
    tempPoint.y = self.photoSize.height - tempPoint.y;
    self.rightEyeballCenter = tempPoint;//右眼球
    
}

///convertEye只包括眼睛，convertEyeAndEyebrow包括眼睛和眉毛
-(void)convertEye{
    
    CGRect tempRect = CGRectZero;
    CGPoint tempPoint = CGPointZero;
    CGSize tempSize = CGSizeZero;
    
    //2.3.1 定义眼睛大小，根据三庭五眼的说法，一只眼睛宽度是脸的1/5
    tempSize.width = self.faceBounds.size.width/4.5;
    tempSize.height = tempSize.width/1.5;
    
    //2.3.2 左眼
    tempPoint = self.leftEyeballCenter;
    tempPoint.x -= tempSize.width/2.0;
    tempPoint.y -= tempSize.height/2.2;
    
    tempRect.origin = tempPoint;
    tempRect.size = tempSize;
    self.leftEyeFrame = tempRect;
    
    //2.3.3 右眼
    tempPoint = self.rightEyeballCenter;
    tempPoint.x -= tempSize.width/2.0;
    tempPoint.y -= tempSize.height/2.2;
    
    tempRect.origin = tempPoint;
    tempRect.size = tempSize;
    self.rightEyeFrame = tempRect;
    
}
///convertEye只包括眼睛，convertEyeAndEyebrow包括眼睛和眉毛
-(void)convertEyeAndEyebrow{
    
    CGRect tempRect = CGRectZero;
    CGPoint tempPoint = CGPointZero;
    CGSize tempSize = CGSizeZero;
    
    //2.3.1 定义眼睛大小，根据三庭五眼的说法，一只眼睛宽度是脸的1/5
    tempSize.width = self.faceBounds.size.width/2.9;
    tempSize.height = tempSize.width;
    
    //2.3.2 左眼
    tempPoint = self.leftEyeballCenter;
    tempPoint.x -= tempSize.width/2.0;
    tempPoint.y -= tempSize.height;
    
    tempRect.origin = tempPoint;
    tempRect.size = tempSize;
    self.leftEyeFrame = tempRect;
    
    //2.3.3 右眼
    tempPoint = self.rightEyeballCenter;
    tempPoint.x -= tempSize.width/2.0;
    tempPoint.y -= tempSize.height;
    
    tempRect.origin = tempPoint;
    tempRect.size = tempSize;
    self.rightEyeFrame = tempRect;
}

-(void)convertMouth{
    
    CGRect tempRect = CGRectZero;
    CGPoint tempPoint = CGPointZero;
    CGSize tempSize = CGSizeZero;
    
    tempPoint = self.faceFeature.mouthPosition;
    tempPoint.y = self.photoSize.height - tempPoint.y;
    self.mouthCenter = tempPoint;
    
    //嘴巴大概是1/3
    tempSize.width = self.faceBounds.size.width/3.0;
    tempSize.height = tempSize.width;
    
    //目前是嘴巴中心的位置，要再转化为左上角的点
    tempPoint.x -= tempSize.width/2.0;
    tempPoint.y -= tempSize.height/2.0;
    
    tempRect.origin = tempPoint;
    tempRect.size = tempSize;
    self.mouthFrame = tempRect;
    
    
}

#pragma mark - 裁剪曲线path
-(void)setEyesPath{
    
    //所有单位都是像素级别
    CGRect ovalRect = CGRectZero;
    
    ovalRect.origin = self.leftEyeFrame.origin;
    ovalRect.size = CGSizeMake(CGRectGetMaxX(self.rightEyeFrame)-self.leftEyeFrame.origin.x, CGRectGetHeight(self.leftEyeFrame));
    
//    UIBezierPath *ovalPath=[UIBezierPath bezierPathWithOvalInRect:ovalRect];
    UIBezierPath *ovalPath=[UIBezierPath bezierPathWithRect:ovalRect];
    
    self.eyesPath = ovalPath.CGPath;
    self.eyesFrame = ovalRect;
}

-(void)setNoseAndMouthPath{
    
    //所有单位都是像素级别
    CGRect ovalRect = CGRectZero;
    
    ovalRect.origin = CGPointMake(self.leftEyeballCenter.x, CGRectGetMaxY(self.leftEyeFrame));
    ovalRect.size = CGSizeMake(self.rightEyeballCenter.x - self.leftEyeballCenter.x, CGRectGetMaxY(self.mouthFrame) - CGRectGetMaxY(self.leftEyeFrame));
    
    //    UIBezierPath *ovalPath=[UIBezierPath bezierPathWithOvalInRect:ovalRect];
    UIBezierPath *ovalPath=[UIBezierPath bezierPathWithRect:ovalRect];
    
    self.noseAndMouthPath = ovalPath.CGPath;
    self.noseAndMouthFrame = ovalRect;
    
}

-(void)setFacePath{
    
    //所有单位都是像素级别
    CGPoint originPoint = self.leftEyeFrame.origin;
    CGPoint curvStartPoint = CGPointMake(originPoint.x, self.mouthCenter.y);
    CGPoint curvEndPoint = CGPointMake(CGRectGetMaxX(self.rightEyeFrame), curvStartPoint.y);
    CGPoint controllPoint = CGPointMake((curvEndPoint.x - curvStartPoint.x)/2.0+originPoint.x, curvStartPoint.y+self.faceBounds.size.height/5.0);
    CGPoint upRightPoint = CGPointMake(CGRectGetMaxX(self.rightEyeFrame), CGRectGetMinY(self.rightEyeFrame));
    
    CGRect rect = CGRectZero;
    rect.origin = originPoint;
    rect.size = CGSizeMake(CGRectGetMaxX(self.rightEyeFrame)-self.leftEyeFrame.origin.x, CGRectGetMaxY(self.mouthFrame)+(self.faceBounds.size.height-CGRectGetMaxY(self.mouthFrame))*.6);
    
    UIBezierPath *ovalPath=[UIBezierPath bezierPathWithRect:rect];
    self.facePath = ovalPath.CGPath;
    
    
    self.faceFrame = rect;
    
}

-(void)setStandardFaceFrame{

    
    //2.3.1 定义眼睛大小，根据三庭五眼的说法，一只眼睛宽度是脸的1/5
    CGFloat eyeWidth = self.faceBounds.size.width/2.3;
    CGFloat faceOriginX = self.leftEyeballCenter.x - eyeWidth/2.0;
    
    
    CGFloat faceTop = self.faceBounds.size.width/5.5;//1/5
    CGFloat faceOriginY = self.faceBounds.origin.y-faceTop;
    
    CGFloat faceRight = eyeWidth*0.92;
    CGFloat faceSizeWidth = self.rightEyeballCenter.x - self.leftEyeballCenter.x + faceRight;
    
    CGFloat mouthBottom = self.faceBounds.size.width/4.5;
    CGFloat faceSizeHeight = self.mouthCenter.y-faceOriginY + mouthBottom;
    
    self.standardFrame = CGRectMake(faceOriginX, faceOriginY, faceSizeWidth, faceSizeHeight);
    
    
}

#pragma mark -
-(CGPathRef)path:(CGSize)size{
    
    //截取的位置大概在2/3左右
    CGPoint originPoint = self.leftEyeFrame.origin;
    CGPoint curvStartPoint = CGPointMake(originPoint.x, self.mouthCenter.y);
    CGPoint curvEndPoint = CGPointMake(CGRectGetMaxX(self.rightEyeFrame), curvStartPoint.y);
    CGPoint controllPoint = CGPointMake((curvEndPoint.x - curvStartPoint.x)/2.0, curvStartPoint.y+50);
    CGPoint upRightPoint = CGPointMake(CGRectGetMaxX(self.rightEyeFrame), CGRectGetMinY(self.rightEyeFrame));
    
    UIBezierPath* aPath = [UIBezierPath bezierPath];
    
    aPath.lineCapStyle = kCGLineCapRound; //线条拐角
    aPath.lineJoinStyle = kCGLineCapRound; //终点处理
    
    [aPath moveToPoint:originPoint];
    [aPath addLineToPoint:curvStartPoint];
    [aPath addQuadCurveToPoint:curvEndPoint controlPoint:controllPoint];
    [aPath addLineToPoint:upRightPoint];
    
    
    return aPath.CGPath;
    
}

@end
