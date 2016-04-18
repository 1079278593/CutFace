//
//  Extension.h
//  photoFance
//
//  Created by ming on 15-3-14.
//  Copyright (c) 2015年 ming. All rights reserved.
//  扩展类，一些公用的

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "UIImageView+WebCache.h"
//1.引用(md5加密)
#import <CommonCrypto/CommonDigest.h>

@interface Extension : NSObject

//虽然可以检测多个人脸，但是目前只返回一个人脸
+(CIFaceFeature *)detectFacesFromPhoto:(UIImage *)photo;
+(CGRect)faceBounds:(UIImage *)photo;
//调整获取的人脸位置的y值
+(CGFloat)getCorrectPointYInPhoto:(UIImage *)photo faceBounds:(CGRect)faceBounds;

//将人脸裁剪出来
+(UIImage *)cutFace:(UIImage *)image cutFrame:(CGRect)cutframe;

#pragma mark 将方形的脸部截图变成瓜子形状的截图
+ (UIImage *)cutSquareFaceToOvalface:(UIImage *)image;

//将人脸按照path再次裁剪，下面创建裁剪路径
#pragma mark 裁剪曲线path
+(CGPathRef)getPath:(CGSize)size;

@end
