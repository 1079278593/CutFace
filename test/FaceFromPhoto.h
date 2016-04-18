//
//  FaceFromPhoto.h
//  test
//
//  Created by ming on 16/4/6.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Extension.h"
#import "UIImage+ImageModify.h"
#import "AVCaptureDataOutput.h"
#import "FaceComponentLocation.h"

@interface FaceFromPhoto : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,CaptureDataOutputDelegate>

@end
