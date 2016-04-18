//
//  FacePositionSpeaker.m
//  test
//
//  Created by ming on 15/11/2.
//  Copyright © 2015年 ming. All rights reserved.
//

#import "FacePositionSpeaker.h"

#define IOS9 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)

////静态实例
static FacePositionSpeaker * facePositionSpeaker = nil;
static AVSpeechSynthesizer * speechSynthesizer = nil;

@implementation FacePositionSpeaker

#pragma mark - 单例
+(FacePositionSpeaker *)facePositionSpeaker{
    @synchronized(self){
        if(facePositionSpeaker == nil){
            
            facePositionSpeaker = [[FacePositionSpeaker alloc] init];
            speechSynthesizer = [[AVSpeechSynthesizer alloc]init];
            
        }
        
    }
    
    return facePositionSpeaker;
}

+(id)allocWithZone:(NSZone *)zone{
    @synchronized(self){
        if (facePositionSpeaker == nil) {
            facePositionSpeaker = [super allocWithZone:zone];
            return  facePositionSpeaker;
        }
    }
    return nil;
}

#pragma mark - 语音提示：矫正位置
//语音提示：矫正位置
-(void)faceCorrectCentreFromPreview:(CGPoint )previewCentre faceViewCentre:(CGPoint )faceCentre{
    
    CGFloat offsetMaxValue = 80;
    
    CGFloat centreXoffset = previewCentre.x - faceCentre.x;
    CGFloat centreYoffset = previewCentre.y - faceCentre.y;
    
    //首先判断是否在规定的范围内
    if (centreXoffset < offsetMaxValue && centreXoffset > -offsetMaxValue && centreYoffset < offsetMaxValue && centreYoffset > -offsetMaxValue) {
        
        [self speakSet:FaceOffset_centre];
        return;
    }
    
    //然后判断X轴
    if (centreXoffset >= offsetMaxValue) {
        
        [self speakSet:FaceOffset_left];
        return;
        
    }else if (centreXoffset <= -offsetMaxValue){
        
        [self speakSet:FaceOffset_right];
        return;
    }
    
    //最后判断Y轴
    if (centreYoffset >= offsetMaxValue) {
        
        [self speakSet:FaceOffset_up];
        return;
        
    }else if (centreYoffset <= -offsetMaxValue){
        
        [self speakSet:FaceOffset_down];
        return;
    }
    
}

#pragma mark speak set
-(void)speakSet:(FaceOffset)faceOffset{

    //保证每一段语音都有3秒的时间
    if (![self canStartSpeaking]) {
        return;//如果有语音正在播放，return
    }
    
    //说什么？
    NSString *speakString = [self getSpeakString:faceOffset];
    //speaking
    [self speaking:speakString];
    

}

#pragma mark get speak word
-(NSString *)getSpeakString:(FaceOffset)faceOffset{
    
    NSString *speakString = @"ok,即将拍照";
    
    switch (faceOffset) {
        case FaceOffset_centre:
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"BlueDataNotification" object:@"5"];
        }
            break;
        case FaceOffset_left:
        {
            speakString = @"右边一点";
        }
            break;
        case FaceOffset_right:
        {
            speakString = @"左边一点";
        }
            break;
        case FaceOffset_up:
        {
            speakString = @"上一点";
        }
            break;
        case FaceOffset_down:
        {
            speakString = @"下一点";
        }
            break;
            
        default:
            break;
    }
    
    return speakString;
    
}

#pragma mark 判断是否能开始speaking

-(BOOL)canStartSpeaking{
    
    if (timer == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"开始计时");
            timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerOut) userInfo:nil repeats:NO];
            
        });
        
        return YES;
    }
    
    return NO;
    
}

-(void)timerOut{
    
    NSLog(@"结束计时");
    [timer invalidate];//先失效
    timer = nil;
    
}

#pragma mark speaking
-(void)speaking:(NSString *)speakString{

    if (![speechSynthesizer continueSpeaking]) {
        
        //    NSArray *voice = [AVSpeechSynthesisVoice speechVoices];
        
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:speakString];  //需要转换的文本
        
        if (IOS9) {
            utterance.rate = .5;//0~1（越来越快）
        }else{
            utterance.rate = .15;//0~1（越来越快）
        }
        
//        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-HK"];
        [speechSynthesizer speakUtterance:utterance];
        
        
    }else{
        
        NSLog(@"正在speak,需要等待上个speech说完");
        
    }
    
}

@end
