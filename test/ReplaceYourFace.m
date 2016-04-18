//
//  ReplaceYourFace.m
//  test
//
//  Created by ming on 16/4/9.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "ReplaceYourFace.h"

@interface ReplaceYourFace (){
    
    UIImage *userFace;
    CGRect userFaceLocation;
    UIImage *originImage;
    UIImage *finalImage;
    
}

@property (strong ,nonatomic)UserfaceInModelView *showImageView;

//裁剪后的用户头像，模特头像
@property (strong ,nonatomic)UIImageView *userfaceView;
@property (strong ,nonatomic)UIImageView *modelfaceView;

@end

@implementation ReplaceYourFace

#pragma mark - event
-(void)btnBack:(UIButton *)button{
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(void)btnCenter:(UIButton *)button{
    
    [self replaceFace];
    [self finalShow];
}

-(void)btnRight:(UIButton *)button{
    
    if (!button.selected) {
        originImage = [UIImage imageNamed:@"man_model_origin.png"];
        finalImage = [UIImage imageNamed:@"man_model_face_nobackcolor.png"];
    }else{
        originImage = [UIImage imageNamed:@"00_womenFace.png"];
        finalImage = [UIImage imageNamed:@"01_womenFace_clear.png"];
    }
    button.selected = !button.selected;
    
    [self btnCenter:nil];
}

-(void)originShow{
    self.showImageView.userFace = userFace;
    self.showImageView.userFaceLocation = userFaceLocation;
    self.showImageView.originImage = originImage;
    self.showImageView.finalImage = finalImage;
    [self.showImageView showOrigin];
}
-(void)finalShow{
    
    self.showImageView.userFace = userFace;
    self.showImageView.userFaceLocation = userFaceLocation;
    self.showImageView.originImage = originImage;
    self.showImageView.finalImage = finalImage;
    [self.showImageView showFinal];
}
#pragma mark - private method


#pragma mark 换脸
-(void)replaceFace{
    
    CIFaceFeature *feature = [Extension detectFacesFromPhoto:self.userPhoto.image];
    FaceComponentLocation *originFaceInfo = [[FaceComponentLocation alloc]init];
    [originFaceInfo convertCoordinate:feature photoSize:self.userPhoto.image.size];
    
    UIImage *eyesImage = [Extension cutFace:self.userPhoto.image cutFrame:originFaceInfo.standardFrame];
    
    //很黑：342824  ，一般黑：783f30 ，红润:F09678
    //女模特：D2B195
    NSData *imageData = [UIImage matchFaceToModel:eyesImage modelSkinColor:@"D2B195"];
    eyesImage = [[UIImage alloc]initWithData:imageData];
    
    eyesImage = [Extension cutSquareFaceToOvalface:eyesImage];
    //1.获得截取的脸
    userFace = eyesImage;
    self.userfaceView.image = userFace;
    
    //---
    CIFaceFeature *targetFeature = [Extension detectFacesFromPhoto:originImage];
    FaceComponentLocation *targetFaceInfo = [[FaceComponentLocation alloc]init];
    [targetFaceInfo convertCoordinate:targetFeature photoSize:originImage.size];
    
    UIImage *eyesImage_target = [Extension cutFace:originImage cutFrame:targetFaceInfo.standardFrame];
    eyesImage_target = [Extension cutSquareFaceToOvalface:eyesImage_target];
    self.modelfaceView.image = eyesImage_target;
    
    CGRect grabArea = targetFaceInfo.standardFrame;
    CGFloat scale = originImage.scale;
    grabArea.origin.x = grabArea.origin.x/scale;
    grabArea.origin.y = grabArea.origin.y/scale;
    grabArea.size.width = grabArea.size.width/scale;
    grabArea.size.height = grabArea.size.height/scale;
    //2.获得模特的脸位置
    userFaceLocation = grabArea;
    
    
}

#pragma mark - init view
-(void)initNavi{
    
    CGFloat buttonWidth = 90.0;
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
    
    //相册
    UIButton *photos = [UIButton buttonWithType:UIButtonTypeCustom];
    photos.frame = CGRectMake((KMainScreenWidth-buttonWidth)/2.0, buttonY, buttonWidth, buttooHeight);
    [photos setTitle:@"换脸" forState:UIControlStateNormal];
    [photos setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [photos setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [self.view addSubview:photos];
    //    button.tag = ButtonTAG + i;
    [photos addTarget:self action:@selector(btnCenter:) forControlEvents:UIControlEventTouchUpInside];
    photos.backgroundColor = [UIColor lightGrayColor];
    
    //换脸前
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake((KMainScreenWidth - buttonWidth), buttonY, buttonWidth, buttooHeight);
    [rightBtn setTitle:@"切换模特" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [self.view addSubview:rightBtn];
    //    button.tag = ButtonTAG + i;
    [rightBtn addTarget:self action:@selector(btnRight:) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.backgroundColor = [UIColor lightGrayColor];
}

-(UserfaceInModelView *)showImageView{
    
    if (_showImageView == nil) {
        
        _showImageView = [[UserfaceInModelView alloc]init];
        _showImageView.backgroundColor = [UIColor clearColor];
        _showImageView.contentMode = UIViewContentModeScaleAspectFit;
        _showImageView.frame = CGRectMake(0, 70, KMainScreenWidth, KMainScreenHeight - 70);
        [self.view addSubview:_showImageView];
        _showImageView.userInteractionEnabled = YES;
    }
    
    return _showImageView;
}

-(UIImageView *)userPhoto{
    
    if (_userPhoto == nil) {
        
        _userPhoto = [[UIImageView alloc]init];
        _userPhoto.backgroundColor = [UIColor grayColor];
        _userPhoto.contentMode = UIViewContentModeScaleAspectFit;
        _userPhoto.frame = CGRectMake(0, 50, 100, 100);
        [self.view addSubview:_userPhoto];
        
    }
    
    return _userPhoto;
    
}

-(UIImageView *)userfaceView{
    
    if (_userfaceView == nil) {
        
        _userfaceView = [[UIImageView alloc]init];
        _userfaceView.backgroundColor = [UIColor grayColor];
        _userfaceView.contentMode = UIViewContentModeScaleAspectFit;
        _userfaceView.frame = CGRectMake(110, 50, 100, 100);
        [self.view addSubview:_userfaceView];
        
    }
    _userfaceView.hidden = YES;
    return _userfaceView;
    
}

-(UIImageView *)modelfaceView{
    
    if (_modelfaceView == nil) {
        
        _modelfaceView = [[UIImageView alloc]init];
        _modelfaceView.backgroundColor = [UIColor grayColor];
        _modelfaceView.contentMode = UIViewContentModeScaleAspectFit;
        _modelfaceView.frame = CGRectMake(220, 50, 100, 100);
        [self.view addSubview:_modelfaceView];
        
    }
    _modelfaceView.hidden = YES;
    return _modelfaceView;
    
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor whiteColor];

    
    originImage = [UIImage imageNamed:@"00_womenFace.png"];
    finalImage = [UIImage imageNamed:@"01_womenFace_clear.png"];
    
//    originImage = [UIImage imageNamed:@"man_model_origin.png"];
//    finalImage = [UIImage imageNamed:@"man_model_face_nobackcolor.png"];
    
    [self initNavi];
    
    [self showImageView];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];

    
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
