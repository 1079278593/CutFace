//
//  FacePositionSpeaker.h
//  test
//
//  Created by ming on 15/11/2.
//  Copyright © 2015年 ming. All rights reserved.
//  情景：后置摄像头自拍，借助语音播报‘人脸的位置’，以此来调整位置

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

typedef enum
{
    FaceOffset_centre,     //中心位置
    FaceOffset_left,        //偏左
    FaceOffset_right,       //偏右
    FaceOffset_up,          //偏上
    FaceOffset_down         //偏下
}FaceOffset;

@interface FacePositionSpeaker : NSObject{
    
    NSTimer *timer;
    
}

+(FacePositionSpeaker *)facePositionSpeaker;

//语音提示：矫正位置
-(void)faceCorrectCentreFromPreview:(CGPoint )previewCentre faceViewCentre:(CGPoint )faceCentre;

#pragma mark speaking
-(void)speaking:(NSString *)speakString;

@end
