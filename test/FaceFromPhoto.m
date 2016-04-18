//
//  FaceFromPhoto.m
//  test
//
//  Created by ming on 16/4/6.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "FaceFromPhoto.h"

@interface FaceFromPhoto (){
    UIView *preview;//预览界面
}

@property (strong,nonatomic)UIImageView *face;
@property (strong,nonatomic)UIImageView *eyeLeft;
@property (strong,nonatomic)UIImageView *eyeRight;
@property (strong,nonatomic)UIImageView *mouth;

@property (strong,nonatomic)UIImageView *photo;
@property (strong,nonatomic)UIButton *cameraSwitchBtn;//前后
@property (strong,nonatomic)UIButton *captureBtn;//拍照

@end

@implementation FaceFromPhoto

#pragma mark - event
-(void)btnBack:(UIButton *)button{
    
    [self dismissViewControllerAnimated:NO completion:^{}];
}

-(void)rightBtn:(UIButton *)button{
    
    //1.只裁剪人脸
//    [self cutFaceFromPhoto];
    
    //2.将脸、眼、嘴巴都裁剪出来cutfaceAndDetail
    [self cutFacedetailFromPhoto];
}

-(void)tapGesture:(UITapGestureRecognizer *)gesture{
    
    _photo.hidden = YES;
    
}
-(void)cameraSwitchAct:(UIButton *)button{
    
    [[AVCaptureDataOutput captureDataOutput] switchCameraPosition];
    
}

-(void)captureAct:(UIButton *)button{
    
    [[AVCaptureDataOutput captureDataOutput] captureStillImage];
    
}


#pragma mark camera delegate
-(void)captureStillImage:(UIImage *)image{
    
//    NSData *imageData = [UIImage matchFaceToModel:image modelSkinColor:@"342824"];
//    image = [[UIImage alloc]initWithData:imageData];
    
    _photo.image = image;
    _photo.hidden = NO;
    
}


#pragma mark - private method
-(void)cutFaceFromPhoto{
    
    CGRect faceFrame = [Extension faceBounds:_photo.image];
    UIImage *faceImage = [Extension cutFace:_photo.image cutFrame:faceFrame];
    _face.image = faceImage;
    
}
//2.将脸、眼、嘴巴都裁剪出来
/**
 所谓的“三庭五眼”是人的脸长与脸宽的一般标准比例，如图所示：从额头顶端到眉毛、从眉毛到鼻子、从鼻子到下巴，各占1/3。脸的宽度以眼睛的宽度为测量标准，分成5个等份
 */
-(void)cutFacedetailFromPhoto{
    
    //1 人脸
    CIFaceFeature *feature = [Extension detectFacesFromPhoto:_photo.image];
    FaceComponentLocation *locationInfo = [[FaceComponentLocation alloc]init];
    [locationInfo convertCoordinate:feature photoSize:_photo.image.size];
    
    
    UIImage *faceImage = [Extension cutFace:_photo.image cutFrame:locationInfo.faceBounds];
    faceImage = [Extension cutSquareFaceToOvalface:faceImage];
    
//    UIImage *faceImage = [_photo.image cutImageWithPath:locationInfo.eyesPath];
    
//    UIImage *faceImage = [Extension cutFace:_photo.image cutFrame:locationInfo.eyesFrame];
    
    //很黑：342824  ，一般黑：783f30 ，红润:F09678
//    NSData *imageData = [UIImage matchFaceToModel:faceImage modelSkinColor:@"342824"];
//    faceImage = [[UIImage alloc]initWithData:imageData];
    _face.image = faceImage;
    
    [self.view addSubview:_face];
    
    //2 左眼
    UIImage *leftEyeImage = [Extension cutFace:_photo.image cutFrame:locationInfo.leftEyeFrame];
    _eyeLeft.image = leftEyeImage;
    
    //3 右眼
    UIImage *rightEyeImage = [Extension cutFace:_photo.image cutFrame:locationInfo.rightEyeFrame];
    _eyeRight.image = rightEyeImage;
    
    //4 嘴巴
    UIImage *mouthImage = [Extension cutFace:_photo.image cutFrame:locationInfo.mouthFrame];
    _mouth.image = mouthImage;
    
    
}
#pragma mark 裁剪曲线path
-(CGPathRef)getPath:(CGSize)size{
    
    //截取的位置大概在2/3左右
    CGPoint originPoint = CGPointZero;
    CGPoint curvStartPoint = CGPointMake(0, size.height*2/3.0);
    CGPoint curvEndPoint = CGPointMake(size.width, size.height*2/3.0);
    CGPoint controllPoint = CGPointMake(size.width/2, size.height*1.2);
    CGPoint upRightPoint = CGPointMake(size.width, 0);
    
    UIBezierPath* aPath = [UIBezierPath bezierPath];
    
    aPath.lineCapStyle = kCGLineCapRound; //线条拐角
    aPath.lineJoinStyle = kCGLineCapRound; //终点处理
    
    [aPath moveToPoint:originPoint];
    [aPath addLineToPoint:curvStartPoint];
    [aPath addQuadCurveToPoint:curvEndPoint controlPoint:controllPoint];
    [aPath addLineToPoint:upRightPoint];
    
    
    return aPath.CGPath;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initNavi];
    
    [self containerForCutted];
    
//    [self initPhoto];
    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self startCamera];
    
    [self initBtn];
    
    [self initPhoto];
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    [self stopCamera];
    
}
-(void)stopCamera{
    
    //停止相机
    [[AVCaptureDataOutput captureDataOutput] sessionStopRunning];
    
}

-(void)startCamera{
    
    CGFloat cameraY = CGRectGetMaxY(_mouth.frame);
    CGFloat cameraHeight = KMainScreenHeight-cameraY;
    CGFloat cameraWidth = 300;
    CGFloat cameraX = (KMainScreenWidth - cameraWidth)/2.0;
    
    preview = [[UIView alloc]init];
    preview.frame = CGRectMake(cameraX, cameraY, cameraWidth, cameraHeight);
    [self.view addSubview:preview];
    preview.backgroundColor = [UIColor clearColor];
    
    [[AVCaptureDataOutput captureDataOutput] setDelegate:self];
    [[AVCaptureDataOutput captureDataOutput] setSessionWithFrame:preview.bounds];
    [preview.layer addSublayer:[[AVCaptureDataOutput captureDataOutput] getPreviewLayer]];
    
}
#pragma mark - getter

-(void)initBtn{
    
    _cameraSwitchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _cameraSwitchBtn.frame = CGRectMake((KMainScreenWidth - 80)/2.0, 0, 80, 50);
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
    rightBtn.frame = CGRectMake((KMainScreenWidth - buttonWidth), buttonY, buttonWidth, buttooHeight);
    [rightBtn setTitle:@"裁剪" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [self.view addSubview:rightBtn];
    //    button.tag = ButtonTAG + i;
    [rightBtn addTarget:self action:@selector(rightBtn:) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.backgroundColor = [UIColor lightGrayColor];
}

///创建被裁剪的后对象的容器
-(void)containerForCutted{
    
    CGFloat width = KMainScreenWidth/4;
    
    _face = [[UIImageView alloc]init];
    _face.backgroundColor = [UIColor lightGrayColor];
    _face.contentMode = UIViewContentModeScaleAspectFit;
    _face.frame = CGRectMake(width*0, 80, width, width);
    [self.view addSubview:_face];
    
    _eyeLeft = [[UIImageView alloc]init];
    _eyeLeft.backgroundColor = [UIColor grayColor];
    _eyeLeft.contentMode = UIViewContentModeScaleAspectFit;
    _eyeLeft.frame = CGRectMake(width*1, 80, width, width);
    [self.view addSubview:_eyeLeft];
    
    _eyeRight = [[UIImageView alloc]init];
    _eyeRight.backgroundColor = [UIColor lightGrayColor];
    _eyeRight.contentMode = UIViewContentModeScaleAspectFit;
    _eyeRight.frame = CGRectMake(width*2, 80, width, width);
    [self.view addSubview:_eyeRight];
    
    _mouth = [[UIImageView alloc]init];
    _mouth.backgroundColor = [UIColor grayColor];
    _mouth.contentMode = UIViewContentModeScaleAspectFit;
    _mouth.frame = CGRectMake(width*3, 80, width, width);
    [self.view addSubview:_mouth];
    
}

-(void)initPhoto{
    
    //  @"ketong.jpg"   @"mayun.jpg"  @"匡1.png"
    UIImage *image = [UIImage imageNamed:@"匡1.png"];
    CGFloat ratio = image.size.width/image.size.height;
    CGFloat width = 200;
    CGFloat heigth = width/ratio;
    
    _photo = [[UIImageView alloc]init];
    _photo.backgroundColor = [UIColor grayColor];
    _photo.contentMode = UIViewContentModeScaleAspectFit;
    _photo.frame = CGRectMake(0, preview.frame.origin.y, KMainScreenWidth, CGRectGetHeight(preview.frame));
    _photo.image = image;
    _photo.hidden = YES;
    [self.view addSubview:_photo];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
    _photo.userInteractionEnabled = YES;
    [_photo addGestureRecognizer:tap];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
