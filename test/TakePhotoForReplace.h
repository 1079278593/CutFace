//
//  TakePhotoForReplace.h
//  test
//
//  Created by ming on 16/4/9.
//  Copyright © 2016年 ming. All rights reserved.
//  自拍照

#import <UIKit/UIKit.h>
#import "AVCaptureDataOutput.h"
#import "ReplaceYourFace.h"
#import "Extension.h"

@interface TakePhotoForReplace : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,CaptureDataOutputDelegate>

@end
