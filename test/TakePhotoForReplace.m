//
//  TakePhotoForReplace.m
//  test
//
//  Created by ming on 16/4/9.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "TakePhotoForReplace.h"

@interface TakePhotoForReplace (){
    UIView *preview;//预览界面
}

@end

@implementation TakePhotoForReplace

#pragma mark - event
-(void)btnBack:(UIButton *)button{
    
    [self dismissViewControllerAnimated:NO completion:^{}];
}

-(void)rightBtn:(UIButton *)button{
    
    [[AVCaptureDataOutput captureDataOutput] captureStillImage];

    
}

-(void)initCamera{
    
    CGFloat cameraY = 70;
    CGFloat cameraHeight = KMainScreenHeight-cameraY;
    CGFloat cameraWidth = 320;
    CGFloat cameraX = 0;
    
    preview = [[UIView alloc]init];
    preview.frame = CGRectMake(cameraX, cameraY, cameraWidth, cameraHeight);
    [self.view addSubview:preview];
    preview.backgroundColor = [UIColor clearColor];
    
    [[AVCaptureDataOutput captureDataOutput] setDelegate:self];
    [[AVCaptureDataOutput captureDataOutput] setSessionWithFrame:preview.bounds];
    [preview.layer addSublayer:[[AVCaptureDataOutput captureDataOutput] getPreviewLayer]];
}

-(void)reStartCamera{
    
    [[AVCaptureDataOutput captureDataOutput] sessionStartRunning];

}
-(void)stopCamera{
    
    //停止相机
    [[AVCaptureDataOutput captureDataOutput] sessionStopRunning];
    
}
#pragma mark camera delegate
-(void)captureStillImage:(UIImage *)image{
    
    CIFaceFeature *feature = [Extension detectFacesFromPhoto:image];
    
    
    if (feature) {
        ReplaceYourFace *replace = [[ReplaceYourFace alloc]init];
        replace.userPhoto.image = image;
        [self presentViewController:replace animated:YES completion:^{}];
    }else{
        
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(0, (KMainScreenHeight - 50)/2.0, KMainScreenWidth, 50);
        label.font = [UIFont systemFontOfSize:15];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor redColor];
        label.text = @"没有发现人脸，请重拍";
        [self.view addSubview:label];
        double delayInSeconds = 2.0;
        dispatch_time_t dismissTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(dismissTime, dispatch_get_main_queue(), ^(void){
            [label removeFromSuperview];
        });
    }
    
    
}
#pragma mark - init view
-(void)initNavi{
    
    CGFloat buttonWidth = 70.0;
    CGFloat buttooHeight = 30.0;
    CGFloat buttonX = 0;
    CGFloat buttonY = 20;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttooHeight);
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [self.view addSubview:button];
    //    button.tag = ButtonTAG + i;
    [button addTarget:self action:@selector(btnBack:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor lightGrayColor];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake((KMainScreenWidth - 70)/2.0, KMainScreenHeight - 60, 70, 50);
    [rightBtn setTitle:@"拍照" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [self.view addSubview:rightBtn];
    //    button.tag = ButtonTAG + i;
    [rightBtn addTarget:self action:@selector(rightBtn:) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.backgroundColor = [UIColor lightGrayColor];
}

-(void)initFaceFrame{
    
    //face_frame.png
    UIImageView *frame = [[UIImageView alloc]init];
    frame.backgroundColor = [UIColor clearColor];
    frame.frame = preview.frame;
    [self.view addSubview:frame];
    
    frame.image = [UIImage imageNamed:@"face_frame.png"];
    
}
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initCamera];
    
    [self initFaceFrame];
    
    [self initNavi];
    
    
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self reStartCamera];
    
    
    
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    [self stopCamera];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
