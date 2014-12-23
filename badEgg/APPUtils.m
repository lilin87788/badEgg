//
//  APPUtils.m
//  NewZhongYan
//
//  Created by lilin on 13-10-8.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "APPUtils.h"
#import "BEAppDelegate.h"
#import "BEViewController.h"
@implementation APPUtils
+(BEAppDelegate*)APPdelegate
{
    BEAppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    return delegate;
}

+(UIStoryboard*)AppStoryBoard
{
    return [UIStoryboard storyboardWithName:@"Main" bundle:nil];
}

+(UIViewController*)visibleViewController
{
    BEAppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    UINavigationController* nav =  (UINavigationController*)delegate.window.rootViewController;
    return [nav visibleViewController];
}

+(BEViewController*)AppRootViewController
{
    UINavigationController* nav =  (UINavigationController*)[[[self APPdelegate] window] rootViewController];
    return (BEViewController*)nav.viewControllers[0];
}

@end
