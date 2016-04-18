//
//  FaceGestureImageView.m
//  test
//
//  Created by ming on 16/4/10.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "FaceGestureImageView.h"

#define KMainScreenHeight [UIScreen mainScreen].bounds.size.height
#define KMainScreenWidth [UIScreen mainScreen].bounds.size.width

@interface FaceGestureImageView ()

/** 相对于原始大小的 缩放倍数*/
@property (assign, nonatomic)float ratio;
/** 旋转角度 以顺时针360度为周期*/
@property (assign, nonatomic)float angle;

@end

@implementation FaceGestureImageView

#pragma mark - gesture
-(void)addGesture{
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAct:)];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAct:)];
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchGestureAct:)];
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotationGestureAct:)];
    
    [self addGestureRecognizer:tapGesture];
    [self addGestureRecognizer:panGesture];
    [self addGestureRecognizer:pinchGesture];
    [self addGestureRecognizer:rotationGesture];
    
}
-(void)panGestureAct:(UIPanGestureRecognizer *)panGesture{
    
    UIView *delegateView = ((UIViewController *)_delegate).view;
    CGPoint translation = [panGesture translationInView:delegateView];
    panGesture.view.center = CGPointMake(panGesture.view.center.x + translation.x,panGesture.view.center.y + translation.y);
    [panGesture setTranslation:CGPointZero inView:delegateView];
    
    NSLog(@"移动 \n 输出移动后self.transform：%@",NSStringFromCGAffineTransform(self.transform));
    
    //调整button位置
    [self setAngel];
    
    
}

-(void)pinchGestureAct:(UIPinchGestureRecognizer *)pinchGesture{
    
    //originViewWidth = 160，可以缩放的宽度范围（40~320），换算为倍数（0.25~2.0)
    CGFloat nextRatio = self.ratio * pinchGesture.scale;
    
    //1.
    if (nextRatio >= .25 && nextRatio <= 2.0) {
        pinchGesture.view.transform = CGAffineTransformScale(pinchGesture.view.transform, pinchGesture.scale, pinchGesture.scale);
        self.ratio *= pinchGesture.scale;//记录缩放倍数
    }else if (nextRatio <.25){
        pinchGesture.view.transform = CGAffineTransformScale(pinchGesture.view.transform, 1, 1);
        self.ratio *= 1;//记录缩放倍数
    }else{
        pinchGesture.view.transform = CGAffineTransformScale(pinchGesture.view.transform, 1, 1);
        self.ratio *= 1;//记录缩放倍数
    }
    
    
    //2.
    pinchGesture.scale = 1;//置为1，注释此句即可看到不同
    NSLog(@"捏合 \n 输出缩放后：倍数：%f \nself.transform：%@",self.ratio,NSStringFromCGAffineTransform(self.transform));
    
    //3.调整button位置
    [self setAngel];
    
    
}

-(void)rotationGestureAct:(UIRotationGestureRecognizer *)rotationGesture{
    
    NSLog(@"观察rotationGesture.rotation 的数值：%f",rotationGesture.rotation);
    
    rotationGesture.view.transform = CGAffineTransformRotate(rotationGesture.view.transform, rotationGesture.rotation * 2.5);
    rotationGesture.rotation = 0;
    
    NSLog(@"旋转 \n 输出旋转后rotationGesture.rotation %f  、self.transform：%@",rotationGesture.rotation,NSStringFromCGAffineTransform(self.transform));
    
    //调整button位置
    [self setAngel];
    
   
    
}

-(void)tapGestureAct:(UITapGestureRecognizer *)tapGesture{
    
    
}

#pragma mark - set the position or angel
-(void)setAngel{
    
    if (self.transform.b == 0||self.transform.c == 0) {
        return;
    }
    
    //self.transform.a = 缩放倍数 * cos(x);
    CGFloat newAngel = [self conversionToAngel:acos(self.transform.a / self.ratio)];
    NSLog(@"新角度：%f",newAngel);
    
    
    //判断象限（顺时针，屏幕为第一象限。）
    if (self.transform.a >= 0 && self.transform.b > 0) {
        //第一象限 0~90
        NSLog(@"第一象限");
    }
    if (self.transform.a >= 0 && self.transform.b < 0) {
        //第四象限 270~360
        NSLog(@"第四象限");
        newAngel = 360 - newAngel;
        
    }
    if (self.transform.a < 0 && self.transform.b > 0) {
        //第二象限 90~180
        NSLog(@"第二象限");
        
    }
    if (self.transform.a < 0 && self.transform.b < 0) {
        //第三象限 180~270
        NSLog(@"第三象限");
        newAngel = 360 - newAngel;
    }
    
    
    self.angle = newAngel;
    
}

#pragma mark 角度转为弧度
-(CGFloat)conversionToRadian:(CGFloat)angel{
    return angel / 180 * M_PI;
}

#pragma mark 弧度转为角度
-(CGFloat)conversionToAngel:(CGFloat)radian{
    return radian / M_PI * 180;
}
#pragma mark - init view

-(id)init{
    
    self = [super init];
    
    if (self) {
        
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addGesture];
        [self setDefaultValue];
        
    }
    
    return self;
    
}
-(void)setDefaultValue{
    
    self.ratio = 1;
    self.angle = 0;
    self.transform = CGAffineTransformIdentity;
}

@end
