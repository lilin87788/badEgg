//
//  BEAppDelegate.h
//  badEgg
//
//  Created by lilin on 13-10-10.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UMFeedback.h"
#import "UMSocialControllerService.h"
#import "AFURLSessionManager.h"
#define System_Version_Small_Than_(v) (DeviceSystemMajorVersion() < v)
#define UMENG_APPKEY @"533d028256240b727e01ed41"
@interface BEAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIStoryboard *mainStoryboard;

NSUInteger DeviceSystemMajorVersion();
+(AFURLSessionManager*)sharedURLSessionManager;
@end

