//
//  ReplaceYourFace.h
//  test
//
//  Created by ming on 16/4/9.
//  Copyright © 2016年 ming. All rights reserved.
//  换脸

#import <UIKit/UIKit.h>
#import "AVCaptureDataOutput.h"
#import "Extension.h"
#import "FaceComponentLocation.h"
#import "FaceGestureImageView.h"
#import "UserfaceInModelView.h"

@interface ReplaceYourFace : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,CaptureDataOutputDelegate>

@property (strong,nonatomic)UIImageView *userPhoto;

@end
