//
//  BEAppDelegate.m
//  badEgg
//
//  Created by lilin on 13-10-10.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BEAppDelegate.h"
#import "Sqlite.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "BEViewController.h"
#import "MobClick.h"

#import "UMSocialFacebookHandler.h"
#import <TencentOpenAPI/QQApiInterface.h>       //手机QQ SDK
#import <TencentOpenAPI/TencentOAuth.h>
#import "UMSocialWechatHandler.h"
#import "UMSocial.h"
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
//    UIImage *tabBackground = [[UIImage imageNamed:@"tabbar.png"]
//                              resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//    [[UITabBar appearance] setBackgroundImage:tabBackground];

//    UIImage *buttonBack30 = [[UIImage imageNamed:@"back"]
//                             resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 13)];
//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:buttonBack30
//                                                      forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
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
    }
    else                                                                    //如果安装过则执行补丁代码
    {
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

- (void)umengTrack {
    //    [MobClick setCrashReportEnabled:NO]; // 如果不需要捕捉异常，注释掉此行
    //[MobClick setLogEnabled:YES];  // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
    [MobClick setAppVersion:XcodeAppVersion]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    //
    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:(ReportPolicy) REALTIME channelId:nil];
    //   reportPolicy为枚举类型,可以为 REALTIME, BATCH,SENDDAILY,SENDWIFIONLY几种
    //   channelId 为NSString * 类型，channelId 为nil或@""时,默认会被被当作@"App Store"渠道
    
    //      [MobClick checkUpdate];   //自动更新检查, 如果需要自定义更新请使用下面的方法,需要接收一个(NSDictionary *)appInfo的参数
    //    [MobClick checkUpdateWithDelegate:self selector:@selector(updateMethod:)];
    
    [MobClick updateOnlineConfig];  //在线参数配置
    
    //    1.6.8之前的初始化方法
    //    [MobClick setDelegate:self reportPolicy:REALTIME];  //建议使用新方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
    
    [UMFeedback checkWithAppkey:UMENG_APPKEY];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(umCheck:) name:UMFBCheckFinishedNotification object:nil];
    
    [UMSocialData setAppKey:UMENG_APPKEY];
    [UMSocialConfig setSupportQzoneSSO:YES importClasses:@[[QQApiInterface class],[TencentOAuth class]]];
    [UMSocialConfig setSupportSinaSSO:YES];
    [UMSocialConfig setQQAppId:@"512103762" url:nil importClasses:@[[QQApiInterface class],[TencentOAuth class]]];
    //设置微信AppId，url地址传nil，将默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:@"wxd9a39c7122aa6516" url:nil];
    [UMSocialConfig setShareQzoneWithQQSDK:YES url:@"http://www.umeng.com/social" importClasses:@[[QQApiInterface class],[TencentOAuth class]]];
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
    [Sqlite createAllTable];
    //[self umengTrack];
    [self customizeAppearance];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [_mainStoryboard instantiateInitialViewController];
    [self.window makeKeyAndVisible];
    return YES;
}

/**
 这里处理新浪微博SSO授权之后跳转回来，和微信分享完成之后跳转回来
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}

/**
 这里处理新浪微博SSO授权进入新浪微博客户端后进入后台，再返回原来应用
 */
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [UMSocialSnsService  applicationDidBecomeActive];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSLog(@"查看feedback");
        //[self.viewController webFeedback:nil];
        BEViewController* controller =  (BEViewController*)self.window.rootViewController;
        [controller feedbackSend];
    } else {
        
    }
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
