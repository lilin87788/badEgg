//
//  APPUtils.h
//  NewZhongYan
//
//  Created by lilin on 13-10-8.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BEAppDelegate;
@class BEViewController;
@interface APPUtils : NSObject
//入口：
//出口：返回APP的delegate
//功能：返回APP的delwgate
//备注：实例函数
+(BEAppDelegate*)APPdelegate;

+(UIStoryboard*)AppStoryBoard;


+(BEViewController*)AppRootViewController;

+(UIViewController*)visibleViewController;
@end
