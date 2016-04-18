//
//  UIImage+ImageModify.h
//  photoFun
//
//  Created by ming on 15/7/30.
//  Copyright (c) 2015年 ming. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct{
    UInt32 Red;
    UInt32 Green;
    UInt32 Blue;
    CGFloat alpha;
}structRGBA;

@interface UIImage (ImageModify)

///修正前置摄像头拍照的左右镜像问题
+ (UIImage *)frontPhotoprocess:(UIImage*)inputImage;

#pragma mark 生成需要角度的image
+ (UIImage*)rotateImageWithRadian:(UIImage *)image rotationRadian:(CGFloat)radian;


#pragma mark 合成图片
+ (UIImage *)processUsingPixels:(UIImage*)inputImage ghostImage:(UIImage *)ghostImage ratioMessage:(CGAffineTransform )transform;

#pragma mark 调整图片的Orientation
- (UIImage *)fixOrientation;

#pragma mark - 新- - - - - - - - - - - - - 
#pragma mark - 给人脸增加一个色素，相当于滤镜
+(NSData *)matchFaceToModel:(UIImage *)faceImage modelSkinColor:(NSString*)RGBAString;

//
+(NSData *)replaceFaceWithHostImage:(UIImage *)hostImage turtledove:(UIImage *)turtledoveImage grabArea:(CGRect)grabArea;


-(UIImage *)cutImage:(CGRect)showframe cutFrame:(CGRect)cutframe;

@end
