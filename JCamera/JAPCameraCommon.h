//
//  JAPCameraCommon.h
//  JAPCamera
//
//  Created by ming on 16/4/7.
//  Copyright © 2016年 juemei. All rights reserved.
//

#ifndef JAPCameraCommon_h
#define JAPCameraCommon_h

#pragma mark - 字体、颜色、高度
#define TextFont(size) [UIFont systemFontOfSize:size]

#define IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IOS9 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#define IPHONE_5_5_inch (KMainScreenHeight == 736)
#define IPHONE_4_7_inch (KMainScreenHeight == 667)
#define IPHONE_4_0_inch (KMainScreenHeight == 568)

#define KMainScreenHeight [UIScreen mainScreen].bounds.size.height
#define KMainScreenWidth [UIScreen mainScreen].bounds.size.width
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#endif /* JAPCameraCommon_h */
