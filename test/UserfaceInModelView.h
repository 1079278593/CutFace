//
//  UserfaceInModelView.h
//  test
//
//  Created by ming on 16/4/16.
//  Copyright © 2016年 ming. All rights reserved.
//  用户的脸替换模特的脸

#import <UIKit/UIKit.h>
#import "FaceGestureImageView.h"

@interface UserfaceInModelView : UIView

/**前三个属性必须赋值，最后一个用于对比，根据需求可传可以不传*/
@property (strong ,nonatomic)UIImage *userFace;
@property (assign ,nonatomic)CGRect userFaceLocation;
@property (strong ,nonatomic)UIImage *originImage;
@property (strong ,nonatomic)UIImage *finalImage;

///显示最终混合的效果
-(void)showFinal;
///显示原始效果
-(void)showOrigin;

@end
