//
//  BEAppDelegate.m
//  badEgg
//
//  Created by lilin on 13-10-10.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BEAppDelegate.h"

#import <UMengMessage/UMessage.h>

#import "Sqlite.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "BEViewController.h"
#import "BETabBarController.h"

#import "BEHttpRequest.h"

//#import "UMSocialFacebookHandler.h"
//#import <TencentOpenAPI/QQApiInterface.h>       //手机QQ SDK
//#import <TencentOpenAPI/TencentOAuth.h>
//#import "UMSocialWechatHandler.h"
//#import "UMSocial.h"
@implementation BEAppDelegate

NSUInteger DeviceSystemMajorVersion() {
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken; dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}

+(AFURLSessionManager*)sharedURLSessionManager{
    static AFURLSessionManager* manager = nil;
    static dispatch_once_t onceToken; dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];        
    });
    return manager;
}

- (void)customizeAppearance
{
    UIImage *backImage = [UIImage imageNamed:@"beBack"];
    backImage = [backImage resizableImageWithCapInsets:UIEdgeInsetsMake(0,backImage.size.width - 1,0, 0)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backImage
                                                      forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar64"] forBarMetrics:UIBarMetricsDefault];
}

-(void)creeateDatabase
{
    //判断以前是不是安装过这个应用
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"CreetDB"])      //如果没有安装过则创建最新的数据库代码
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CreetDB"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DBVERSION"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [Sqlite  createAllTable];
    } else  {
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"DBVERSION"])//这里保证补丁代码只执行一次
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DBVERSION"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [Sqlite setDBVersion];
        }
    }
}
- (void)onlineConfigCallBack:(NSNotification *)note {
    
    NSLog(@"online config has fininshed and note = %@", note.userInfo);
}

- (void)umengTrack:(NSDictionary *)launchOptions{
    [MobClick setCrashReportEnabled:NO]; // 如果不需要捕捉异常，注释掉此行
    //[MobClick setLogEnabled:YES];  // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
    [MobClick setAppVersion:XcodeAppVersion]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:(ReportPolicy) REALTIME channelId:nil];
    //[MobClick updateOnlineConfig];  //在线参数配置
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];

    
    
    [UMFeedback setAppkey:UMENG_APPKEY];

    [UMessage setLogEnabled:NO];
    [UMessage startWithAppkey:UMENG_APPKEY launchOptions:launchOptions];
    if (IOS_8_OR_LATER) {
        //register remoteNotification types
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
        action1.identifier = @"action1_identifier";
        action1.title=@"Accept";
        action1.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
        
        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  //第二按钮
        action2.identifier = @"action2_identifier";
        action2.title=@"Reject";
        action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
        action2.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
        action2.destructive = YES;
        
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
        categorys.identifier = @"category1";//这组动作的唯一标示
        [categorys setActions:@[action1,action2] forContext:(UIUserNotificationActionContextDefault)];
        
        UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert
                                                                                     categories:[NSSet setWithObject:categorys]];
        [UMessage registerRemoteNotificationAndUserNotificationSettings:userSettings];
    } else {
        [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeSound |
         UIRemoteNotificationTypeAlert];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkFinished:)
                                                 name:UMFBCheckFinishedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:nil
                                               object:nil];
    
//    [UMSocialData setAppKey:UMENG_APPKEY];
//    [UMSocialConfig setSupportQzoneSSO:YES importClasses:@[[QQApiInterface class],[TencentOAuth class]]];
//    [UMSocialConfig setSupportSinaSSO:YES];
//    [UMSocialConfig setQQAppId:@"512103762" url:nil importClasses:@[[QQApiInterface class],[TencentOAuth class]]];
//    //设置微信AppId，url地址传nil，将默认使用友盟的网址
//    [UMSocialWechatHandler setWXAppId:@"wxd9a39c7122aa6516" url:nil];
//    [UMSocialConfig setShareQzoneWithQQSDK:YES url:@"http://www.umeng.com/social" importClasses:@[[QQApiInterface class],[TencentOAuth class]]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"%@",NSHomeDirectory());
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:40 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];

    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
    }];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

    
    [self creeateDatabase];
    [self customizeAppearance];
   // [self umengTrack:launchOptions];
    return YES;
}

#pragma mark - Remote Notification
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [UMessage didReceiveRemoteNotification:userInfo];
    [UMFeedback didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [UMessage registerDeviceToken:deviceToken];
    NSLog(@"umeng message alias is: %@", [UMFeedback uuid]);
    [UMessage addAlias:[UMFeedback uuid] type:[UMFeedback messageType] response:^(id responseObject, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

///**
// 这里处理新浪微博SSO授权之后跳转回来，和微信分享完成之后跳转回来
// */
//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//{
//    return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
//}

/**
 这里处理新浪微博SSO授权进入新浪微博客户端后进入后台，再返回原来应用
 */
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //[UMSocialSnsService  applicationDidBecomeActive];
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

- (void)applicationWillTerminate:(UIApplication *)application
{

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:NSLocalizedString(@"new feedback", nil)])
    {
        if (buttonIndex == 1) // "open" button
        {
            //这里需要改
            UINavigationController *currentVC = (UINavigationController *)[(UITabBarController *)self.window.rootViewController selectedViewController];
            [currentVC pushViewController:[UMFeedback feedbackViewController]
                                 animated:YES];
        }
    }
}

- (void)receiveNotification:(id)receiveNotification {
    //    NSLog(@"receiveNotification = %@", receiveNotification);
}

- (void)checkFinished:(NSNotification *)notification {
    NSLog(@"class checkFinished = %@", notification);
}

- (void)umCheck:(NSNotification *)notification {
    UIAlertView *alertView;
    if (notification.userInfo) {
        NSArray *newReplies = [notification.userInfo objectForKey:@"newReplies"];
        unsigned long count = [newReplies count];
        NSString *title = [NSString stringWithFormat:@"有%lu条新回复",count];
        NSMutableString *content = [NSMutableString string];
        for (int i = 0; i < [newReplies count]; i++) {
            
            NSString *dateTime = [[newReplies objectAtIndex:i] objectForKey:@"datetime"];
            NSString *_content = [[newReplies objectAtIndex:i] objectForKey:@"content"];
            [content appendString:[NSString stringWithFormat:@"%d .......%@.......\r\n",(i + 1), dateTime]];
            [content appendString:_content];
            [content appendString:@"\r\n\r\n"];
        }
        
        alertView = [[UIAlertView alloc] initWithTitle:title message:content delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查看", nil];
        if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0f) {
            ((UILabel *) [[alertView subviews] objectAtIndex:1]).textAlignment = NSTextAlignmentLeft;
        }
    } else {
        //alertView = [[UIAlertView alloc] initWithTitle:@"没有新回复" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
    }
    [alertView show];
}
@end
