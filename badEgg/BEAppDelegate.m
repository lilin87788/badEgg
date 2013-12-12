//
//  BEAppDelegate.m
//  badEgg
//
//  Created by lilin on 13-10-10.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BEAppDelegate.h"

@implementation BEAppDelegate

NSUInteger DeviceSystemMajorVersion() {
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken; dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}

- (void)customizeAppearance
{
//    UIImage *tabBackground = [[UIImage imageNamed:@"tabbar.png"]
//                              resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//    [[UITabBar appearance] setBackgroundImage:tabBackground];

//    UIImage *buttonBack30 = [[UIImage imageNamed:@"back"]
//                             resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 13)];
//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:buttonBack30
//                                                      forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

-(void)initAudioSession
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    if (System_Version_Small_Than_(7)) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
            _mainStoryboard = [UIStoryboard storyboardWithName:@"Main_ios6" bundle:nil];
        }else {
            _mainStoryboard = [UIStoryboard storyboardWithName:@"Main_ios5" bundle:nil];
        }
    }else{
        _mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    }
    
    [self customizeAppearance];
    [self initAudioSession];//
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [_mainStoryboard instantiateInitialViewController];
    [self.window makeKeyAndVisible];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{

}

@end
