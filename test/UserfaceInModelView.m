//
//  UserfaceInModelView.m
//  test
//
//  Created by ming on 16/4/16.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "UserfaceInModelView.h"

@interface UserfaceInModelView ()

@property (strong ,nonatomic)UIImageView *showImageView;
@property (strong ,nonatomic)UIImageView *userFaceView;

@end


@implementation UserfaceInModelView

///显示最终混合的效果
-(void)showFinal{
    
    if ([self isCorrectConfig]) {
        
        [self setShowImageFrame];
        self.showImageView.image = self.finalImage;
        
        [self setUserfaceFrame];
        self.userFaceView.image = self.userFace;
        
        
    }else{
        NSLog(@"参数不全，没脸可换");
    }
    
}

///显示原始效果
-(void)showOrigin{
    
    if ([self isCorrectConfig]) {
        
        [self setShowImageFrame];
        self.showImageView.image = self.originImage;
        
        
    }else{
        NSLog(@"参数不全，没脸可换");
    }
    
    
    
}

#pragma mark - private method
-(BOOL)isCorrectConfig{
    
    if (self.userFace && self.finalImage) {
        if (self.userFaceLocation.size.width >0 && self.userFaceLocation.size.height >0) {
            return YES;
        }
    }
    return NO;
}

///finalImage和originImage唯一的区别是脸部镂空用于替换用户的脸。所以二者的size是一样的
-(void)setShowImageFrame{
    
    CGFloat imageSizeRatio = self.originImage.size.width/self.originImage.size.height;
//    CGFloat selfViewSizeRatio = self.frame.size.width/self.frame.size.height;
    
    if (imageSizeRatio>=1) {
        
        //宽屏/横屏，确定了showImage的width
        CGFloat imageWidth = CGRectGetWidth(self.frame);
        CGFloat imageHeight = imageWidth / imageSizeRatio;
        
        CGFloat imageX = 0;
        CGFloat imageY = (CGRectGetHeight(self.frame)-imageHeight)/2.0;
        self.showImageView.frame = CGRectMake(imageX, imageY, imageWidth, CGRectGetHeight(self.frame));
        
    }else{
        
        //窄屏/竖屏,确定了showImage的height
        CGFloat imageHeight = CGRectGetHeight(self.frame);
        CGFloat imageWidth = imageHeight * imageSizeRatio;
        
        CGFloat imageX = (CGRectGetWidth(self.frame) - imageWidth)/2.0;
        CGFloat imageY = 0;
        self.showImageView.frame = CGRectMake(imageX, imageY, imageWidth, CGRectGetHeight(self.frame));
    }
    
}

-(void)setUserfaceFrame{
    
    //showImageView
    
    CGRect userFrame = CGRectZero;
    CGSize showImageSize = self.showImageView.image.size;

    userFrame.origin.x = (self.userFaceLocation.origin.x / showImageSize.width) * self.showImageView.frame.size.width;
    userFrame.origin.y = (self.userFaceLocation.origin.y / showImageSize.height) * self.showImageView.frame.size.height;
    userFrame.size.width = (self.userFaceLocation.size.width / showImageSize.width) * self.showImageView.frame.size.width;
    userFrame.size.height = (self.userFaceLocation.size.height / showImageSize.height) * self.showImageView.frame.size.height;
    
    
//    userFrame = [self.showImageView convertRect:userFrame toView:self];
//    self.userFaceView.frame = userFrame;
//    return;
    //向右微调
    userFrame.origin.x +=4;
    
    CGFloat imageRatio = self.userFace.size.width/self.userFace.size.height;
    
    //中心点，不变，变换宽高
    CGPoint center = CGPointMake(CGRectGetMidX(userFrame), CGRectGetMidY(userFrame));
    
    //变换宽高
    userFrame.size.width += 6*2;
    userFrame.size.height = userFrame.size.width/imageRatio;
    
    userFrame = [self.showImageView convertRect:userFrame toView:self];
    //最终中心点
    center = [self.showImageView convertPoint:center toView:self];
    
    
    self.userFaceView.frame = userFrame;
    self.userFaceView.center = center;

    
}

#pragma mark - gesture
-(void)addGesture{
    
    self.userInteractionEnabled = YES;
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureAct:)];
    longPressGesture.minimumPressDuration = .3;
    longPressGesture.allowableMovement = YES;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAct:)];
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAct:)];
//    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchGestureAct:)];
    
//    [self addGestureRecognizer:tapGesture];
//    [self addGestureRecognizer:pinchGesture];
    [self addGestureRecognizer:panGesture];
    
    [self addGestureRecognizer:longPressGesture];
    
}

-(void)panGestureAct:(UIPanGestureRecognizer *)panGesture{
    
    CGPoint translation = [panGesture translationInView:self];
    NSLog(@"%@",NSStringFromCGPoint(translation));
    CGPoint center = CGPointMake(self.userFaceView.center.x + translation.x, self.userFaceView.center.y + translation.y);
    self.userFaceView.center = center;
    
    [panGesture setTranslation:CGPointZero inView:self];
}

-(void)longPressGestureAct:(UILongPressGestureRecognizer *)panGesture{
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        [self showOrigin];
    }
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        [self showFinal];
    }
    
    
}
#pragma mark - life cycle
-(id)init{
    
    self = [super init];
    if (self) {
        //两者有先后顺序
        [self userFaceView];
        [self showImageView];
        [self addGesture];
    }
    
    return self;
}

-(void)dealloc{
    
}

#pragma mark - getter
-(UIImageView *)showImageView{
    
    if (_showImageView == nil) {
        
        _showImageView = [[UIImageView alloc]init];
        _showImageView.backgroundColor = [UIColor clearColor];
        _showImageView.contentMode = UIViewContentModeScaleAspectFit;
        _showImageView.userInteractionEnabled = NO;
        [self addSubview:_showImageView];
        
    }

    return _showImageView;
    
}

-(UIImageView *)userFaceView{
    
    if (_userFaceView == nil) {
        
        _userFaceView = [[UIImageView alloc]init];
        _userFaceView.backgroundColor = [UIColor clearColor];
        _userFaceView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_userFaceView];
    }
    
    return _userFaceView;
    
}
@end
