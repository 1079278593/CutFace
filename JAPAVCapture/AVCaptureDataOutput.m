//
//  AVCaptureDataOutput.m
//  test
//
//  Created by ming on 15/12/9.
//  Copyright © 2015年 ming. All rights reserved.
//

#import "AVCaptureDataOutput.h"

////静态实例
static AVCaptureDataOutput * captureDataOutput = nil;

@interface AVCaptureDataOutput ()

@property (strong,nonatomic) AVCaptureSession *captureSession;//负责输入和输出设备之间的数据传递
@property (strong,nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;//相机拍摄预览图层

///物理设备
@property (strong, nonatomic) AVCaptureDevice *captureDevice;

@property (strong,nonatomic) AVCaptureDeviceInput *captureDeviceInput;//输入：从AVCaptureDevice获得输入数据
@property (strong,nonatomic) AVCaptureStillImageOutput *captureStillImageOutput;//输出：静态照片输出流
@property (strong, nonatomic) AVCaptureVideoDataOutput *captureVideoDataOutput;//输出：VideoData
@property (strong, nonatomic) AVCaptureMetadataOutput *captureMetadataOutput;//输出：Metadata

@end

@implementation AVCaptureDataOutput

#pragma mark - method for external call
//
/*
 iphone: 4_inch
 320 * 568 （640x1136
 
 iphone: 4.7_inch
 375 * 667 （750×1334

 iphone: 5.5_inch
 414 * 736 （1242×2208

 */
-(void)setSessionWithFrame:(CGRect)frame{
    
    //初始化会话
    self.captureSession=[[AVCaptureSession alloc]init];
//    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {//设置分辨率
//        self.captureSession.sessionPreset=AVCaptureSessionPreset1920x1080;
//    }else if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {//设置分辨率
//        self.captureSession.sessionPreset=AVCaptureSessionPreset1280x720;
//    }else
        if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {//设置分辨率
        self.captureSession.sessionPreset=AVCaptureSessionPreset640x480;
    }
    
    
    //创建视频预览层，用于实时展示摄像头状态
    self.captureVideoPreviewLayer=[[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    
    self.captureVideoPreviewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;//填充模式
//    self.captureVideoPreviewLayer.bounds=frame;
//    self.captureVideoPreviewLayer.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    self.captureVideoPreviewLayer.frame = frame;
    
    //获得输入设备
    AVCaptureDevice *captureDevice=[self cameraWithPosition:AVCaptureDevicePositionFront];//默认前置摄像头
    self.captureDevice = captureDevice;
    if (!captureDevice) {
        NSLog(@"取得摄像头时出现问题.");
        return;
    }
    
    NSError *error=nil;
    //输入:初始化设备输入对象，用于获得输入数据
    self.captureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:&error];
    if (error) {
        NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    
    //将设备输入添加到会话中
    if ([self.captureSession canAddInput:self.captureDeviceInput]) {
        [self.captureSession addInput:self.captureDeviceInput];
    }
    
    //静态输出:初始化设备输出对象，用于获得输出数据
    [self addStillImageOutput];
    
    //输出所有捕获到的数据流（所有）
//    [self addRealTimeOutput];
    
    //输出所有捕获到的‘目标’数据流（检测到人脸、、）
    [self addResultOutput];
    
    //启动
    [self sessionStartRunning];
    
    //默认前置摄像头
    [self captureInputDeviceWithPosition:AVCaptureDevicePositionFront];
    
}

///启动
-(void)sessionStartRunning{
    
    [self.captureSession startRunning];
    
}

///停止
-(void)sessionStopRunning{
    
    [self.captureSession stopRunning];
    
    self.isOpenVoiceTakePhoto = NO;
    
}

///切换前后摄像头
-(void)switchCameraPosition{
    
    if ([self getCameraPosition] == AVCaptureDevicePositionBack){
        
        [self captureInputDeviceWithPosition:AVCaptureDevicePositionFront];
    }
    else {
        [self captureInputDeviceWithPosition:AVCaptureDevicePositionBack];
    }
    
    
}

///设置前后摄像头
-(void)captureInputDeviceWithPosition:(AVCaptureDevicePosition)position{
    
    // indicate that some changes will be made to the session
    [self.captureSession beginConfiguration];
 
    // remove existing input
    AVCaptureInput* currentCameraInput = [self.captureSession.inputs objectAtIndex:0];
    [self.captureSession removeInput:currentCameraInput];
    
    AVCaptureDevice *newCamera = [self cameraWithPosition:position];
    
    // add input to session
    NSError *error = nil;
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&error];
    
    if(error) {
        
        [self.captureSession commitConfiguration];
        
    }
    
    [self.captureSession addInput:newVideoInput];
    
    [self.captureSession commitConfiguration];
    
    self.captureDevice = newCamera;
    
}

///返回YES代表有闪光灯
-(BOOL)hasFlash{
    
    return self.captureDevice.isFlashAvailable;
    
}
///setOpen = yes代表打开闪光灯，否则关闭
-(void)setFlashMode:(BOOL)setOpen{
    
    AVCaptureFlashMode flashMode;
    
    if (setOpen) {
        flashMode = AVCaptureFlashModeOn;
    }else{
        flashMode = AVCaptureFlashModeOff;
    }
    
    NSError *error;
    if ([self.captureDevice isFlashModeSupported:flashMode]) {
        
        if([self.captureDevice lockForConfiguration:&error]) {
            
            self.captureDevice.flashMode = flashMode;
            [self.captureDevice unlockForConfiguration];
            
        }
    }
    
    
}

///显示
-(AVCaptureVideoPreviewLayer *)getPreviewLayer{
    
    return self.captureVideoPreviewLayer;
    
}

-(AVCaptureDevicePosition)getCameraPosition{
    
    AVCaptureInput* currentCameraInput = [self.captureSession.inputs objectAtIndex:0];
    
    return ((AVCaptureDeviceInput*)currentCameraInput).device.position;
}
//放大
-(void)deviceZoomIn{
    [self deviceZoom:2];
}
//缩小
-(void)deviceZoomOut{
    [self deviceZoom:-2];
}

-(void)deviceZoom:(CGFloat)factor{
    
    NSError *error = nil;
    
    [self.captureDevice lockForConfiguration:&error];
    if (!error) {
        CGFloat zoomFactor;
        CGFloat scale = self.captureDevice.videoZoomFactor + factor;
        if (scale < 1.0f) {
        // 4
            zoomFactor = 1;
        }else{
            // 5
            zoomFactor = scale;
        }
        // 6
        zoomFactor = MIN(10.0f, zoomFactor);
        zoomFactor = MAX(1.0f, zoomFactor);
        // 7
        self.captureDevice.videoZoomFactor = zoomFactor;
        // 8
        [self.captureDevice unlockForConfiguration];
    }
    
}

#pragma mark 拍照
-(void)captureStillImage{
    
    if (!self.captureSession) {
        return;//error
    }
    
    // get connection and set orientation
    AVCaptureConnection *videoConnection = [self captureConnection];
    videoConnection.videoOrientation = [self orientationForConnection];
    
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        
        UIImage *image = nil;
        NSDictionary *metadata = nil;
        
        // check if we got the image buffer
        if (imageSampleBuffer != NULL) {
            CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
            if(exifAttachments) {
                metadata = (__bridge NSDictionary*)exifAttachments;
            }
            
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            image = [[UIImage alloc] initWithData:imageData];
            
            //------------
            if ([self getCameraPosition] == AVCaptureDevicePositionFront){
                
                int oriention = image.imageOrientation;
                
                image = [UIImage frontPhotoprocess:image];
                image = [UIImage rotateImageWithRadian:image rotationRadian:[self imageRotateAngle]];
                
                oriention = image.imageOrientation;
            }
            //-------
            
            
            if ([self.delegate respondsToSelector:@selector(captureStillImage:)]) {
                [self.delegate captureStillImage:image];
            }
            
            
        }
        
        
    }];
}

#pragma mark - set camera output
/**
 *  取得指定位置的摄像头
 *
 *  @param position 摄像头位置
 *
 *  @return 摄像头设备
 */
-(AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position]==position) {
            return camera;
        }
    }
    return nil;
}

///add output with the stillImageOutput
-(void)addStillImageOutput{
    
    self.captureStillImageOutput=[[AVCaptureStillImageOutput alloc]init];
    NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    [self.captureStillImageOutput setOutputSettings:outputSettings];//输出设置
    
    //将设备输出添加到会话中
    if ([self.captureSession canAddOutput:self.captureStillImageOutput]) {
        [self.captureSession addOutput:self.captureStillImageOutput];
    }
    
}

///实时输出所有‘捕获到的数据流’
-(void)addRealTimeOutput{
    
    // Image capture CORE IMAGE EXCITEMENT
    self.captureVideoDataOutput = [AVCaptureVideoDataOutput new];
    
    // Keep the native pixel format YUV420BiPlanar.
    self.captureVideoDataOutput.videoSettings = nil;
    
    // Set the delegate callback. DON'T USE THE MAIN QUEUE or you shall reap naught but woe and misery and a blocked UI.
    //1.
    [self.captureVideoDataOutput setSampleBufferDelegate:self
                                        queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    [self.captureSession addOutput:self.captureVideoDataOutput];
    
}

///实时输出所有‘目标数据流’
-(void)addResultOutput{
  
    self.captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.captureSession addOutput:self.captureMetadataOutput];

    // Create a new serial dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [self.captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [self.captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeFace]];
    
}

#pragma mark - delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
//    NSLog(@"发现脸");
    [self getFaceInfoFromMetadataArray:metadataObjects];
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection{

//    NSLog(@"数据流");
    
}

#pragma mark - private method

///分析获取人脸的信息
-(void)getFaceInfoFromMetadataArray:(NSArray *)metadataObjects{
    
    for ( AVMetadataObject *object in metadataObjects ) {
        
        if ( [[object type] isEqual:AVMetadataObjectTypeFace] ) {
            
            AVMetadataFaceObject* face = (AVMetadataFaceObject*)object;
            
            AVMetadataFaceObject * adjusted = (AVMetadataFaceObject*)[self.captureVideoPreviewLayer transformedMetadataObjectForMetadataObject:face];
            
            //1. adjust face frame
            if ([self.delegate respondsToSelector:@selector(captureFaceFrmae:)]) {
                [self.delegate captureFaceFrmae:adjusted.bounds];
            }
            //            [self setFaceFrame:adjusted.bounds];
            
            //2. the voice tell to adjust position
            if (self.isOpenVoiceTakePhoto) {
                CGPoint previewCentre = CGPointMake(CGRectGetMinX(_captureVideoPreviewLayer.frame) + CGRectGetWidth(_captureVideoPreviewLayer.frame)/2.0, CGRectGetMinY(_captureVideoPreviewLayer.frame) + CGRectGetHeight(_captureVideoPreviewLayer.frame)/2.0);
                CGPoint faceCentre = CGPointMake(CGRectGetMinX(adjusted.bounds) + CGRectGetWidth(adjusted.bounds)/2.0, CGRectGetMinY(adjusted.bounds) + CGRectGetHeight(adjusted.bounds)/2.0);
                
                //语音调整
                [[FacePositionSpeaker facePositionSpeaker]faceCorrectCentreFromPreview:previewCentre faceViewCentre:faceCentre];
            }
            
            
            //            CMTime timestamp = [face time];
            //            CGRect faceRectangle = [face bounds];
            //            NSInteger faceID = [face faceID];
            //            CGFloat rollAngle = [face rollAngle];
            //            CGFloat yawAngle = [face yawAngle];
            // use this id for tracking
            //            NSNumber* faceID1 = @(face.faceID);
            
            // Do interesting things with this face
            //            NSLog(@"%@",NSStringFromCGRect(adjusted.bounds));
        }
        
    }
    
}

///
- (AVCaptureConnection *)captureConnection {
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.captureStillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    
    return videoConnection;
}

- (AVCaptureVideoOrientation)orientationForConnection
{
    AVCaptureVideoOrientation videoOrientation = AVCaptureVideoOrientationPortrait;
    
    //是否调整方向，一般设置yes
    if(YES) {
        switch ([UIDevice currentDevice].orientation) {
            case UIDeviceOrientationLandscapeLeft:
                // yes we to the right, this is not bug!
                videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            case UIDeviceOrientationLandscapeRight:
                videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            default:
                videoOrientation = AVCaptureVideoOrientationPortrait;
                break;
        }
    }
    else {
        switch (self.interfaceOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
                videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case UIInterfaceOrientationLandscapeRight:
                videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            default:
                videoOrientation = AVCaptureVideoOrientationPortrait;
                break;
        }
    }
    
    return videoOrientation;
}

///将图片长宽对调，用于相机横向拍照的旋转裁剪
- (UIImage *)cutImageWithPreviewLayerBounds:(UIImage *)image {
    
    CGRect outputRect = [self.captureVideoPreviewLayer metadataOutputRectOfInterestForRect:self.captureVideoPreviewLayer.bounds];
    CGImageRef takenCGImage = image.CGImage;
    size_t width = CGImageGetWidth(takenCGImage);
    size_t height = CGImageGetHeight(takenCGImage);
    CGRect cropRect = CGRectMake(outputRect.origin.x * width, outputRect.origin.y * height, outputRect.size.width * width, outputRect.size.height * height);
    
    CGImageRef cropCGImage = CGImageCreateWithImageInRect(takenCGImage, cropRect);
    image = [UIImage imageWithCGImage:cropCGImage scale:1 orientation:image.imageOrientation];
    CGImageRelease(cropCGImage);
    
    return image;
}

-(CGFloat)imageRotateAngle{
    
    CGFloat angleRadian = 0;
    
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationFaceUp:
            NSLog(@"螢幕朝上平躺");
            break;
            
        case UIDeviceOrientationFaceDown:
            NSLog(@"螢幕朝下平躺");
            break;
            
            //系統無法判斷目前Device的方向，有可能是斜置
        case UIDeviceOrientationUnknown:
            NSLog(@"未知方向");
            break;
            
        case UIDeviceOrientationLandscapeLeft:{
            NSLog(@"螢幕向左橫置");
            angleRadian = -0.5;
        }
            
            break;
            
        case UIDeviceOrientationLandscapeRight:{
            NSLog(@"螢幕向右橫置");
            //pose朝相反的方向旋转
            angleRadian = 0.5;
        }
            
            break;
            
        case UIDeviceOrientationPortrait:{
            NSLog(@"螢幕直立");
            angleRadian = 0;
        }
            
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:{
            NSLog(@"螢幕直立，上下顛倒");
            angleRadian = 1;
        }
            
            break;
            
        default:
            NSLog(@"無法辨識");
            break;
    }
    
    return angleRadian * M_PI;
}
#pragma mark - 单例
+(AVCaptureDataOutput *)captureDataOutput{
    @synchronized(self){
        if(captureDataOutput == nil){
            
            captureDataOutput = [[AVCaptureDataOutput alloc] init];
            
            //不开启语音提示
            [captureDataOutput setIsOpenVoiceTakePhoto:NO];

        }
        
    }
    
    return captureDataOutput;
}

+(id)allocWithZone:(NSZone *)zone{
    @synchronized(self){
        if (captureDataOutput == nil) {
            captureDataOutput = [super allocWithZone:zone];
            return  captureDataOutput;
        }
    }
    return nil;
}
@end
