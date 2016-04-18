//
//  JAPCamera.m
//  JAPCamera
//
//  Created by ming on 16/4/7.
//  Copyright © 2016年 juemei. All rights reserved.
//

#import "JAPCamera.h"
#define CameraSize CGSizeMake(KMainScreenWidth, KMainScreenWidth/.75)

@interface JAPCamera (){
    
    CGRect CameraHeightFull;//相机的frame
    UIView *preview;//预览界面
    
    
}

@property (strong,nonatomic)UIButton *zoomInBtn;//放大
@property (strong,nonatomic)UIButton *zoomOutBtn;//缩小

@property (strong,nonatomic)UIButton *cameraSwitchBtn;//前后
@property (strong,nonatomic)UIButton *captureBtn;//拍照
@property (strong,nonatomic)UIImageView *capturePhoto;

@end

@implementation JAPCamera

#pragma mark - event
-(void)zoomInAct:(UIButton *)button{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(void)zoomOutAct:(UIButton *)button{
    
    
}

-(void)cameraSwitchAct:(UIButton *)button{
    
    [[AVCaptureDataOutput captureDataOutput] switchCameraPosition];
    
}

-(void)captureAct:(UIButton *)button{
    
    [[AVCaptureDataOutput captureDataOutput] captureStillImage];
    
}

-(void)tapGesture:(UITapGestureRecognizer *)gesture{
    self.capturePhoto.hidden = YES;
}

#pragma mark - init View
-(void)initBtn{
    
    _zoomInBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _zoomInBtn.frame = CGRectMake(0, 20, 80, 50);
    [_zoomInBtn setTitle:@"返回" forState:UIControlStateNormal];
    [self.view addSubview:_zoomInBtn];
    _zoomInBtn.backgroundColor = [UIColor lightGrayColor];
    [_zoomInBtn addTarget:self action:@selector(zoomInAct:) forControlEvents:UIControlEventTouchUpInside];
    
    _zoomOutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _zoomOutBtn.frame = CGRectMake(KMainScreenWidth-80, 20, 80, 50);
    [_zoomOutBtn setTitle:@"换脸前" forState:UIControlStateNormal];
//    [self.view addSubview:_zoomOutBtn];
    _zoomOutBtn.backgroundColor = [UIColor lightGrayColor];
    [_zoomOutBtn addTarget:self action:@selector(zoomOutAct:) forControlEvents:UIControlEventTouchUpInside];
    
    _cameraSwitchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _cameraSwitchBtn.frame = CGRectMake((KMainScreenWidth - 80)/2.0, 20, 80, 50);
    [_cameraSwitchBtn setTitle:@"切换" forState:UIControlStateNormal];
    [self.view addSubview:_cameraSwitchBtn];
    _cameraSwitchBtn.backgroundColor = [UIColor lightGrayColor];
    [_cameraSwitchBtn addTarget:self action:@selector(cameraSwitchAct:) forControlEvents:UIControlEventTouchUpInside];
    
    _captureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _captureBtn.frame = CGRectMake((KMainScreenWidth - 80)/2.0, KMainScreenHeight-50, 80, 50);
    [_captureBtn setTitle:@"拍照" forState:UIControlStateNormal];
    [self.view addSubview:_captureBtn];
    _captureBtn.backgroundColor = [UIColor lightGrayColor];
    [_captureBtn addTarget:self action:@selector(captureAct:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)initCameraPreview{
    
    CGFloat naviRatio = 88.0 / (88.0 + 98.0);
    CGFloat naviBarHeight = (KMainScreenHeight - CameraSize.height) * naviRatio;
    
    if (KMainScreenHeight >= 568) {
        CameraHeightFull = CGRectMake(0, naviBarHeight, CameraSize.width, CameraSize.height);
    }else{
        CameraHeightFull = CGRectMake(0, 0, CameraSize.width, CameraSize.height);
    }
    
    preview = [[UIView alloc]init];
    preview.frame = CameraHeightFull;
    [self.view addSubview:preview];
    preview.backgroundColor = [UIColor clearColor];
    
}

-(UIImageView *)capturePhoto{
    
    if (_capturePhoto == nil) {
        _capturePhoto = [[UIImageView alloc]init];
        _capturePhoto.contentMode = UIViewContentModeScaleAspectFit;
        _capturePhoto.frame = CGRectMake(0, 0, KMainScreenWidth, KMainScreenHeight);
        _capturePhoto.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:_capturePhoto];
        _capturePhoto.hidden = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        _capturePhoto.userInteractionEnabled = YES;
        [_capturePhoto addGestureRecognizer:tap];


    }
    
    return _capturePhoto;
    
}
#pragma mark - camera
-(void)initFunCamera{
    
    [[AVCaptureDataOutput captureDataOutput] setDelegate:self];
    [[AVCaptureDataOutput captureDataOutput] setSessionWithFrame:preview.bounds];
    [preview.layer addSublayer:[[AVCaptureDataOutput captureDataOutput] getPreviewLayer]];
    
}

-(void)captureStillImage:(UIImage *)image{
    
    NSData *imageData = [UIImage matchFaceToModel:image modelSkinColor:@"F09678"];
    image = [[UIImage alloc]initWithData:imageData];
    
//    UIImageView *normalImage = [[UIImageView alloc]initWithFrame:CGRectZero];
//    normalImage.frame = CGRectMake(0, 0, 150, 150);
//    normalImage.contentMode = UIViewContentModeScaleAspectFit;
//    normalImage.backgroundColor = [UIColor lightGrayColor];
//    normalImage.image = image;
//    [self.view addSubview:normalImage];
    

    self.capturePhoto.image = image;
    self.capturePhoto.hidden = NO;
    
}

#pragma mark - life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    
    [self initCameraPreview];
    
    //初始并开启后台相机
    [self initFunCamera];
    
    [self capturePhoto];
    
    [self initBtn];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //重新激活相机
    [[AVCaptureDataOutput captureDataOutput] sessionStartRunning];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    
    
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    //停止相机
    [[AVCaptureDataOutput captureDataOutput] sessionStopRunning];
    
}

//隐藏状态栏方法，如果设置为NO：iPad顶部出现20像素黑边，iPhone上状态栏和导航栏重叠不合设计稿要求
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
