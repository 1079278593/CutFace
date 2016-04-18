//
//  Extension.m
//  photoFance
//
//  Created by ming on 15-3-14.
//  Copyright (c) 2015年 ming. All rights reserved.
//

#import "Extension.h"
#define KMainScreenHeight [UIScreen mainScreen].bounds.size.height
#define KMainScreenWidth [UIScreen mainScreen].bounds.size.width
#define IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@implementation Extension

#pragma mark - 返回人脸坐标
+(CGRect)faceBounds:(UIImage *)photo{
    
    CIFaceFeature *faceFeatures = [self detectFacesFromPhoto:photo];
    CGRect faceBounds = CGRectZero;
    if (faceFeatures) {
        faceBounds = faceFeatures.bounds;
    }
    
    if (faceBounds.size.width == faceBounds.size.height && faceBounds.size.width == 0) {
        return faceBounds;
    }
    
    faceBounds.origin.y = [self getCorrectPointYInPhoto:photo faceBounds:faceBounds];
    
    
    return faceBounds;
    
}

//虽然可以检测多个人脸，但是目前只返回一个人脸
+(CIFaceFeature *)detectFacesFromPhoto:(UIImage *)photo
{
    CIImage* image = [CIImage imageWithCGImage:photo.CGImage];
    
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyLow forKey:CIDetectorAccuracy]];
    
    NSArray* features = [detector featuresInImage:image];
    //    NSLog(@"%f---%f",facePicture.size.width,facePicture.size.height);
    NSLog(@"发现：%d个人脸",features.count);
    
    CIFaceFeature *face;
    for(CIFaceFeature* faceObject in features)
    {
        NSLog(@"found face \nbounds:%@",NSStringFromCGRect(faceObject.bounds));
        //        CGRect modifiedFaceBounds = faceObject.bounds;
        //        modifiedFaceBounds.origin.y = facePicture.size.height-faceObject.bounds.size.height-faceObject.bounds.origin.y;
        face = faceObject;
        
    }
    
    photo = nil;
    return face;
    
}

+(CGFloat)getCorrectPointYInPhoto:(UIImage *)photo faceBounds:(CGRect)faceBounds{
    
    //需要做调整，返回的bounds是从下往上计算的
    return (photo.size.height - faceBounds.origin.y - faceBounds.size.height);
    
}
#pragma mark - 裁剪人脸
+(UIImage *)cutFace:(UIImage *)image cutFrame:(CGRect)cutframe
{
    //    CGRect rect231 = self.view.frame;
//    CGSize imageSize = image.size;

    image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([image CGImage], cutframe)];
    
    return image;
 
}
#pragma mark 将方形的脸部截图变成瓜子形状的截图
+ (UIImage *)cutSquareFaceToOvalface:(UIImage *)image{
    

    CGSize size = CGSizeMake(image.size.width * image.scale, image.size.height * image.scale);
    CGPathRef path = [self getPath:size];
    
    //1.1 根据当前image的size创建image的‘context’
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //1.2 往当前的context里增加path，计算出path在context里的bounds。
    CGContextBeginPath(context);
    CGContextAddPath(context, path);
    CGContextClosePath(context);
    CGRect boundsRect = CGContextGetPathBoundingBox(context);
    UIGraphicsEndImageContext();
    
    //2.1使用path的bounds创建一个image的‘context’
    UIGraphicsBeginImageContext(boundsRect.size);
    context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, CGRectMake(0, 0, boundsRect.size.width, boundsRect.size.height));
    
    CGMutablePathRef  pathNew = CGPathCreateMutable();
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-boundsRect.origin.x, -boundsRect.origin.y);
    CGPathAddPath(pathNew, &transform, path);
    
    CGContextBeginPath(context);
    CGContextAddPath(context, pathNew);
    CGContextClip(context);
    
    [image drawInRect:CGRectMake(-boundsRect.origin.x, -boundsRect.origin.y, image.size.width * image.scale, image.size.height * image.scale)];
    
    UIImage *imageNew = UIGraphicsGetImageFromCurrentImageContext();
    //    image = self;
    
    CGPathRelease(pathNew);
    CGContextRelease(context);
    UIGraphicsEndImageContext();
    
    
    return imageNew;
    
}
#pragma mark 裁剪曲线path
+(CGPathRef)getPath:(CGSize)size{
    
    /**
     1.额头水平方向四分之一为原始点
     2.height的一半为
     */
    CGPoint originPoint = CGPointMake(size.width*0.3, 0);
    CGPoint curvPoint1 = CGPointMake(0, size.height*0.5);
    CGPoint curvPoint2 = CGPointMake(size.width*0.5, size.height);
    CGPoint curvPoint3 = CGPointMake(size.width, size.height*0.5);
    CGPoint curvPoint4 = CGPointMake(size.width*0.7, 0);
    
    CGPoint controllPoint_0_1 = CGPointZero;
    CGPoint controllPoint_1_2 = CGPointMake(size.width*0.125, size.height);
    CGPoint controllPoint_2_3 = CGPointMake(size.width*0.875, size.height);
    CGPoint controllPoint_3_4 = CGPointMake(size.width, 0);
    
    
    UIBezierPath* aPath = [UIBezierPath bezierPath];
    
    aPath.lineCapStyle = kCGLineCapRound; //线条拐角
    aPath.lineJoinStyle = kCGLineCapRound; //终点处理
    
    [aPath moveToPoint:originPoint];
    [aPath addQuadCurveToPoint:curvPoint1 controlPoint:controllPoint_0_1];
    [aPath addQuadCurveToPoint:curvPoint2 controlPoint:controllPoint_1_2];
    [aPath addQuadCurveToPoint:curvPoint3 controlPoint:controllPoint_2_3];
    [aPath addQuadCurveToPoint:curvPoint4 controlPoint:controllPoint_3_4];
    
    return aPath.CGPath;
}
#pragma mark 裁剪后‘可能会改变方向’
+ (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
//    NSLog(@"%ld",aImage.imageOrientation);
    if (aImage.imageOrientation == UIImageOrientationUp){
        return aImage;
    }
    
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


@end
