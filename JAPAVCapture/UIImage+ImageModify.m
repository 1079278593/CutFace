//
//  UIImage+ImageModify.m
//  photoFun
//
//  Created by ming on 15/7/30.
//  Copyright (c) 2015年 ming. All rights reserved.
//

#import "UIImage+ImageModify.h"

#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )
#define A(x) ( Mask8(x >> 24) )
#define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )

@implementation UIImage (ImageModify)

#pragma mark - 给人脸增加一个色素，相当于滤镜
+(NSData *)matchFaceToModel:(UIImage *)faceImage modelSkinColor:(NSString*)RGBAString{
    
    structRGBA RGBA = [self convertRGBAString:RGBAString];
    
    //转换为Core Graphic
    CGImageRef faceCGImage = [faceImage CGImage];
    NSUInteger width = CGImageGetWidth(faceCGImage);
    NSUInteger height = CGImageGetHeight(faceCGImage);
    
    //分配空间
    NSUInteger bytesPerPixel = 4;//每个像素4个字节
    NSUInteger bitsPerComponent = 8;//每个字节8位bit
    NSUInteger bytesPerRow = bytesPerPixel * width;//每行字节数
    
    UInt32 *pixels;
    pixels = (UInt32 *)calloc(width * height, sizeof(UInt32));
    
    //定义颜色空间为32RGBA
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), faceCGImage);
    
    UInt32 *currentPixel = pixels;
    for (NSUInteger j = 0; j < height; j++) {
        for (NSUInteger i = 0; i < width; i++) {
            
            currentPixel = pixels + j*width + i;
            UInt32 color = *currentPixel;
            
            // Blend the ghost with 50% alpha
            CGFloat faceAlpha = 0.35;
            UInt32 newR = R(color) * (1 - faceAlpha) + RGBA.Red * faceAlpha;
            UInt32 newG = G(color) * (1 - faceAlpha) + RGBA.Green * faceAlpha;
            UInt32 newB = B(color) * (1 - faceAlpha) + RGBA.Blue * faceAlpha;
            
            //Clamp, not really useful here :p
            newR = MAX(0,MIN(255, newR));
            newG = MAX(0,MIN(255, newG));
            newB = MAX(0,MIN(255, newB));
            
            *currentPixel = RGBAMake(newR, newG, newB, A(color));
            if (A(color)<.8) {
//                NSLog(@"alpha：%d",A(color));
            }
        }
    }
    
    // --- 4. Create a new UIImage ---
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage * newImage = [UIImage imageWithCGImage:newCGImage];
    NSData *data = UIImageJPEGRepresentation(newImage, 1);
    
    // --- 5. Cleanup! ---
    CGImageRelease(newCGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(pixels);
    
    return data;
    
}

+(structRGBA)convertRGBAString:(NSString *)RGBAString{
    
    if (RGBAString.length == 6) {
        
        int red = strtoul([[RGBAString substringWithRange:NSMakeRange(0, 2)] UTF8String],0,16);
        int green = strtoul([[RGBAString substringWithRange:NSMakeRange(2, 2)] UTF8String],0,16);
        int blue = strtoul([[RGBAString substringWithRange:NSMakeRange(4, 2)] UTF8String],0,16);
        structRGBA RGBA = {red,green,blue,1};
        return RGBA;
    }
    
    structRGBA RGBA = {1,1,1,0};//调成白色透明
    return RGBA;
    
}

+(NSData *)replaceFaceWithHostImage:(UIImage *)hostImage turtledove:(UIImage *)turtledoveImage grabArea:(CGRect)grabArea{
    
    grabArea = CGRectMake((NSUInteger)grabArea.origin.x, (NSUInteger)grabArea.origin.y, (NSUInteger)grabArea.size.width, (NSUInteger)grabArea.size.height);
    structRGBA RGBA = [self convertRGBAString:@"F09678"];
    
    //转换为Core Graphic
    CGImageRef hostCGImage = [hostImage CGImage];
    NSUInteger width = CGImageGetWidth(hostCGImage);
    NSUInteger height = CGImageGetHeight(hostCGImage);
    
    //分配空间
    NSUInteger bytesPerPixel = 4;//每个像素4个字节
    NSUInteger bitsPerComponent = 8;//每个字节8位bit
    NSUInteger bytesPerRow = bytesPerPixel * width;//每行字节数
    
    UInt32 *pixels;
    pixels = (UInt32 *)calloc(width * height, sizeof(UInt32));
    
    //定义颜色空间为32RGBA
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), hostCGImage);
    
    // --- 2. Blend the ghost onto the image ---
    
    CGImageRef turtledoveCGImage = [turtledoveImage CGImage];
    //turtledove的size需要设置成和graArea一样大
    CGSize turtledoveSize = CGSizeMake((NSUInteger)grabArea.size.width, (NSUInteger)grabArea.size.height);
    
    // 2.1 创建一张幽灵图像的缓存图
    
    NSUInteger turtledoveBytesPerRow = bytesPerPixel * turtledoveSize.width;
    
    UInt32 * turtledovePixels = (UInt32 *)calloc(turtledoveSize.width * turtledoveSize.height, sizeof(UInt32));
    
    CGContextRef turtledoveContext = CGBitmapContextCreate(turtledovePixels, turtledoveSize.width, turtledoveSize.height,bitsPerComponent, turtledoveBytesPerRow, colorSpace,kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(turtledoveContext, CGRectMake(0, 0, turtledoveSize.width, turtledoveSize.height),turtledoveCGImage);
    
    //计算偏移量
    NSUInteger offsetPixel = grabArea.origin.y * width + grabArea.origin.x;
    
    //设置循环遍历的值
    NSUInteger traverseHeight = grabArea.size.height;
    NSUInteger traverseWidth = grabArea.size.width;
    
    for (NSUInteger j = 0; j < traverseHeight; j++) {
        for (NSUInteger i = 0; i < traverseWidth; i++) {
            
            UInt32 *hostPixel = pixels + offsetPixel + j*width + i;
            
            UInt32 *turtledovePixel = turtledovePixels + j*traverseWidth + i;
            UInt32 turtledoveColor = *turtledovePixel;
            
            if (turtledoveColor != 0) {
                *hostPixel = turtledoveColor;
            }
            
            
            
        }
    }
    
    // --- 4. Create a new UIImage ---
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage * newImage = [UIImage imageWithCGImage:newCGImage];
    NSData *data = UIImageJPEGRepresentation(newImage, 1);
    
    // --- 5. Cleanup! ---
    CGImageRelease(newCGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CGContextRelease(turtledoveContext);
    free(pixels);
    free(turtledovePixels);
    
    return data;
    
}
#pragma mark -
+ (UIImage *)frontPhotoprocess:(UIImage*)inputImage {
    
    // 1. Get the raw pixels of the image
    UInt32 * inputPixels;
    
    CGImageRef inputCGImage = [inputImage CGImage];
    NSUInteger inputWidth = CGImageGetWidth(inputCGImage);
    NSUInteger inputHeight = CGImageGetHeight(inputCGImage);
    NSLog(@"inputImgeSize宽：%ld  高：%ld",inputWidth,inputHeight);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    
    inputPixels = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    
    CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight,
                                                 bitsPerComponent, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), inputCGImage);
    
    //2.create a nil image
    UIImage *CTMImage = [UIImage imageNamed:@""];
    CGImageRef CTMCGImage = [CTMImage CGImage];
    
    NSUInteger CTMBytesPerRow = bytesPerPixel * inputHeight;
    UInt32 * CTMPixels = (UInt32 *)calloc(inputHeight*inputWidth, sizeof(UInt32));
    
    CGContextRef CTMcontext = CGBitmapContextCreate(CTMPixels, inputHeight, inputWidth,
                                                    bitsPerComponent, CTMBytesPerRow, colorSpace,
                                                    kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(CTMcontext, CGRectMake(0, 0, inputHeight, inputWidth),CTMCGImage);
    
    for (NSUInteger j = 0; j < inputHeight; j++) {
        for (NSUInteger i = 0; i < inputWidth; i++) {
            
            UInt32 * inputPixel = inputPixels + j * inputWidth + i ;
            UInt32 * CTMPixel = CTMPixels + i * inputHeight + j ;
            //            UInt32 * CTMPixel = CTMPixels + j * inputWidth + inputWidth-i ;
            UInt32 inputColor = *inputPixel;
            //            NSLog(@"inputColor:%d",inputColor);
            *CTMPixel = inputColor;
        }
    }
    
    //
    
    
    
    
    // . Create a new UIImage
    CGImageRef newCGImage = CGBitmapContextCreateImage(CTMcontext);
    UIImage * processedImage = [UIImage imageWithCGImage:newCGImage];
    
    // . Cleanup!
    CGImageRelease(newCGImage);
    CGImageRelease(CTMCGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CGContextRelease(CTMcontext);
    free(inputPixels);
    free(CTMPixels);
    
    return processedImage;
    
}

#pragma mark cut image
-(UIImage *)cutImage:(CGRect)showframe cutFrame:(CGRect)cutframe{
    
    CGImageRef inputCGImage = [self CGImage];
    NSUInteger inputWidth = CGImageGetWidth(inputCGImage);
    NSUInteger inputHeight = CGImageGetHeight(inputCGImage);
    NSLog(@"inputImgeSize宽：%ld  高：%ld",inputWidth,inputHeight);
    
    //in fact ratioY == ratioX
    CGFloat ratioX = cutframe.origin.x/showframe.size.width;
    CGFloat ratioY = cutframe.origin.y/showframe.size.height;
    
    //in fact ratioHeight == ratioWidth
    CGFloat ratioWidth = cutframe.size.width/showframe.size.width;
    CGFloat ratioHeight = cutframe.size.height/showframe.size.height;
    
    // 1. Get the raw pixels of the image
    UInt32 * inputPixels;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    
    inputPixels = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    
    CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight,
                                                 bitsPerComponent, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), inputCGImage);
    
    //2.create a nil image
    UIImage *CTMImage = [UIImage imageNamed:@""];
    CGImageRef CTMCGImage = [CTMImage CGImage];
    
    NSUInteger newHeight = inputHeight*ratioHeight;
    NSUInteger newWidth = inputWidth*ratioWidth;
    
    NSUInteger CTMBytesPerRow = bytesPerPixel * newWidth;
    
    UInt32 * CTMPixels = (UInt32 *)calloc(newHeight*newWidth, sizeof(UInt32));
    
    CGContextRef CTMcontext = CGBitmapContextCreate(CTMPixels, newWidth, newHeight,
                                                    bitsPerComponent, CTMBytesPerRow, colorSpace,
                                                    kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(CTMcontext, CGRectMake(0, 0, newWidth, newHeight),CTMCGImage);
    
    NSUInteger offsetX = (NSUInteger)(ratioX * inputWidth);
    NSUInteger offsetY = (NSUInteger)(ratioY * inputHeight);
    NSUInteger pixelOffset = offsetX + offsetY * inputWidth;

    for (NSUInteger j = 0; j < newHeight; j++) {
        for (NSUInteger i = 0; i < newWidth; i++) {
            
            UInt32 * inputPixel = inputPixels + pixelOffset + j * inputWidth + i ;
            UInt32 * CTMPixel = CTMPixels + j * newWidth + i ;
            //            UInt32 * CTMPixel = CTMPixels + j * inputWidth + inputWidth-i ;
            UInt32 inputColor = *inputPixel;
            //            NSLog(@"inputColor:%d",inputColor);
            *CTMPixel = inputColor;
        }
    }
    
    //
    
    
    
    
    // . Create a new UIImage
    CGImageRef newCGImage = CGBitmapContextCreateImage(CTMcontext);
    UIImage * processedImage = [UIImage imageWithCGImage:newCGImage];
    
    // . Cleanup!
    CGImageRelease(newCGImage);
    CGImageRelease(CTMCGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CGContextRelease(CTMcontext);
    free(inputPixels);
    free(CTMPixels);
    
    return processedImage;
    
    return nil;
}
#pragma mark 生成需要角度的image
+ (UIImage*)rotateImageWithRadian:(UIImage *)image rotationRadian:(CGFloat)radian
{
    
    CGSize imgSize = CGSizeMake(image.size.width * image.scale, image.size.height * image.scale);
    CGSize outputSize = imgSize;
    
    //旋转
    //进入if:旋转后的图片可能会比原图大，所有的图片信息都会保留，剩下的区域会是全透明的
    //不进入if:旋转后的图片和原图一样大，部分图片区域会被裁剪掉
    if (1) {
        
        CGRect rect = CGRectMake(0, 0, imgSize.width, imgSize.height);
        rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeRotation(radian));
        outputSize = CGSizeMake(CGRectGetWidth(rect), CGRectGetHeight(rect));
        
    }
    
    UIGraphicsBeginImageContext(outputSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, outputSize.width / 2, outputSize.height / 2);
    CGContextRotateCTM(context, radian);
    CGContextTranslateCTM(context, -imgSize.width / 2, -imgSize.height / 2);
    
    [image drawInRect:CGRectMake(0, 0, imgSize.width, imgSize.height)];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - 合成图片
/**
 
    传入的参数有：inputImage(背景图片)、ghostImage(被合成图片)
    //下面三个都是比例：某个点/某个size ->在背景的相对位置比例
    basePoint(比例：‘背景图’的起始合成‘比例点’)
    ghostPoint(比例：‘合成图’的起始合成‘比例点’)
    sameSize(比例：宽高,重合部分)
 
 */
+ (UIImage *)processUsingPixels:(UIImage*)inputImage ghostImage:(UIImage *)ghostImage ratioMessage:(CGAffineTransform )transform{
    
//    CGAffineTransform transform;
    
    CGPoint basePoint = CGPointMake(transform.a, transform.b);
    CGPoint ghostPoint = CGPointMake(transform.c, transform.d);
    CGSize sameSize = CGSizeMake(transform.tx, transform.ty);
    
    NSLog(@"inputImgeSize:%@ \n ghostImageSize:%@",NSStringFromCGSize(inputImage.size),NSStringFromCGSize(ghostImage.size));
    
    
    // --- 1. Get the raw pixels of the image ---
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    
    UInt32 * inputPixels;
    
    CGImageRef inputCGImage = [inputImage CGImage];
    NSUInteger inputWidth = CGImageGetWidth(inputCGImage);
    NSUInteger inputHeight = CGImageGetHeight(inputCGImage);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    inputPixels = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    
    CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight,
                                                 bitsPerComponent, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), inputCGImage);
    
    // --- 2. Blend the ghost onto the image ---
    
    CGSize ghostSize = CGSizeMake(inputWidth * sameSize.width, inputHeight *sameSize.height);

    CGImageRef ghostCGImage = [ghostImage CGImage];

    // 2.1 创建一张幽灵图像的缓存图
    NSUInteger ghostBytesPerRow = bytesPerPixel * ghostSize.width;
    
    UInt32 * ghostPixels = (UInt32 *)calloc(ghostSize.width * ghostSize.height, sizeof(UInt32));
    
    CGContextRef ghostContext = CGBitmapContextCreate(ghostPixels, ghostSize.width, ghostSize.height,
                                                      bitsPerComponent, ghostBytesPerRow, colorSpace,
                                                      kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(ghostContext, CGRectMake(0, 0, ghostSize.width, ghostSize.height),ghostCGImage);
    
    // --- 3 Blend each pixel ---
    
    basePoint = CGPointMake(basePoint.x * inputWidth, basePoint.y * inputHeight);
    ghostPoint = CGPointMake(ghostPoint.x * ghostSize.width, ghostPoint.y * ghostSize.height);
    
    NSUInteger offsetPixelInput = basePoint.y * inputWidth + basePoint.x;
    NSUInteger offsetPixelGhost = ghostPoint.y * ghostSize.width + ghostPoint.x;


    for (NSUInteger j = 0; j < ghostSize.height; j++) {
        for (NSUInteger i = 0; i < ghostSize.width; i++) {
           
            UInt32 * inputPixel = inputPixels + offsetPixelInput + j * inputWidth + i ;
        
            UInt32 inputColor = *inputPixel;
            
            UInt32 * ghostPixel = ghostPixels + offsetPixelGhost + j * (NSUInteger)ghostSize.width + i;
            UInt32 ghostColor = *ghostPixel;
            
            // Blend the ghost with 50% alpha
            CGFloat ghostAlpha = 1.0f * (A(ghostColor) / 255.0);
            UInt32 newR = R(inputColor) * (1 - ghostAlpha) + R(ghostColor) * ghostAlpha;
            UInt32 newG = G(inputColor) * (1 - ghostAlpha) + G(ghostColor) * ghostAlpha;
            UInt32 newB = B(inputColor) * (1 - ghostAlpha) + B(ghostColor) * ghostAlpha;
            
            //Clamp, not really useful here :p
            newR = MAX(0,MIN(255, newR));
            newG = MAX(0,MIN(255, newG));
            newB = MAX(0,MIN(255, newB));
            
            *inputPixel = RGBAMake(newR, newG, newB, A(inputColor));
        }
    }

    
    // --- 4. Create a new UIImage ---
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage * processedImage = [UIImage imageWithCGImage:newCGImage];
    
    // --- 5. Cleanup! ---
    CGImageRelease(newCGImage);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CGContextRelease(ghostContext);
    free(inputPixels);
    free(ghostPixels);
    
    return processedImage;
}

- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
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
