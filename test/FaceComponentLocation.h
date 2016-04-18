//
//  FaceComponentLocation.h
//  test
//
//  Created by ming on 16/4/9.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

@interface FaceComponentLocation : NSObject{
    
}

///传入CIFaceFeature，其中的坐标系是左下角为原点，区别是Y值不同，所以需要转换下
-(void)convertCoordinate:(CIFaceFeature *)feature photoSize:(CGSize)size;


///保存传入的信息
@property (assign,nonatomic)CGSize photoSize;
@property (strong,nonatomic)CIFaceFeature *faceFeature;


///人脸在整张图中的frame
@property (assign,nonatomic)CGRect faceBounds;


///眼球中心
@property (assign,nonatomic)CGPoint leftEyeballCenter;
@property (assign,nonatomic)CGPoint rightEyeballCenter;


///眼睛的frame，不包括眉毛，因为刘海发型会挡住眉毛
@property (assign,nonatomic)CGRect leftEyeFrame;
@property (assign,nonatomic)CGRect rightEyeFrame;


///嘴巴的frame
@property (assign,nonatomic)CGRect mouthFrame;
@property (assign,nonatomic)CGPoint mouthCenter;

///path 或者 frame
@property (assign,nonatomic)CGPathRef eyesPath;
@property (assign,nonatomic)CGRect eyesFrame;

@property (assign,nonatomic)CGPathRef noseAndMouthPath;
@property (assign,nonatomic)CGRect noseAndMouthFrame;

@property (assign,nonatomic)CGPathRef facePath;
@property (assign,nonatomic)CGRect faceFrame;

///专门为裁剪项目做得人脸frame
@property (assign,nonatomic)CGRect standardFrame;

@end
