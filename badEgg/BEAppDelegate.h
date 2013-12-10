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
#define System_Version_Small_Than_(v) (DeviceSystemMajorVersion() < v)
@interface BEAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIStoryboard *mainStoryboard;
@property (nonatomic, retain) AVQueuePlayer *queuePlayer;

NSUInteger DeviceSystemMajorVersion();
@end
