//
//  AVCaptureDataOutput.h
//  test
//
//  Created by ming on 15/12/9.
//  Copyright © 2015年 ming. All rights reserved.
//  获取‘摄像头’输出信息

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/CGImageProperties.h>
#import "UIImage+ImageModify.h"
#import "FacePositionSpeaker.h"

@protocol CaptureDataOutputDelegate <NSObject>

///检测到人脸后，返回信息
-(void)captureFaceFrmae:(CGRect)faceFrame;

///获取静态图后，返回image
-(void)captureStillImage:(UIImage *)image;

@end

@interface AVCaptureDataOutput : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureMetadataOutputObjectsDelegate>

+(AVCaptureDataOutput *)captureDataOutput;

@property (strong,nonatomic)id delegate;

-(void)setSessionWithFrame:(CGRect)frame;

///启动
-(void)sessionStartRunning;

///停止
-(void)sessionStopRunning;

//获取当前的设备position（前置还是后置）
-(AVCaptureDevicePosition)getCameraPosition;

///切换前后摄像头
-(void)switchCameraPosition;
///设置前后摄像头
-(void)captureInputDeviceWithPosition:(AVCaptureDevicePosition)position;

///返回YES代表有闪光灯
-(BOOL)hasFlash;
///setOpen = yes代表打开闪光灯，否则关闭
-(void)setFlashMode:(BOOL)setOpen;

-(void)deviceZoomIn;//放大
-(void)deviceZoomOut;//缩小

///是否语音提示，矫正位置，用于SmartCameraController
@property (assign,nonatomic)BOOL isOpenVoiceTakePhoto;

///显示
-(AVCaptureVideoPreviewLayer *)getPreviewLayer;

///拍照
-(void)captureStillImage;

@end
