//
//  BEMOREController.m
//  badEgg
//
//  Created by lilin on 13-11-13.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BEMOREController.h"
#import "SKPlaceholderTextView.h"
@interface BEMOREController ()
@property (weak, nonatomic) IBOutlet SKPlaceholderTextView *feedbackTextView;
@property (weak, nonatomic) IBOutlet UITextField *feedbacUserfield;

@end

@implementation BEMOREController

-(void)initNavBar
{
    self.navigationItem.backBarButtonItem.title = @"返回";
    UIImage* navbgImage;
    if (System_Version_Small_Than_(7)) {
        navbgImage = [UIImage imageNamed:@"navbar44"];
    }else{
        navbgImage = [UIImage imageNamed:@"navbar64"] ;
    }
    [self.navigationController.navigationBar setBackgroundImage:navbgImage forBarMetrics:UIBarMetricsDefault];
}

-(void)initData
{
    _umFeedback = [UMFeedback sharedInstance];
    [_umFeedback setAppkey:UMENG_APPKEY delegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    [_feedbackTextView setPlaceholder:@"请您输入宝贵的意见:"];
    [_feedbackTextView setPlaceholderColor:COLOR(150, 150, 150)];
    [_feedbackTextView setTextColor:COLOR(150, 150, 150)];
    [_feedbackTextView.layer setCornerRadius:4];
    [_feedbacUserfield setTextColor:COLOR(150, 150, 150)];
    [self initNavBar];
}

-(IBAction)showShareList:(id)sender
{
    NSString *shareText = @"友盟社会化组件可以让移动应用快速具备社会化分享、登录、评论、喜欢等功能，并提供实时、全面的社会化数据统计分析服务。 http://www.umeng.com/social";             //分享内嵌文字
    UIImage *shareImage = [UIImage imageNamed:@"UMS_social_demo"];          //分享内嵌图片
    
    //如果得到分享完成回调，需要设置delegate为self
    [UMSocialSnsService presentSnsIconSheetView:self appKey:UMENG_APPKEY shareText:shareText shareImage:shareImage shareToSnsNames:nil delegate:self];
}

-(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
{
    if ([platformName isEqualToString:UMShareToSina]) {
        socialData.shareText = @"分享到新浪微博";
    }
    else{
        socialData.shareText = @"分享内嵌文字";
    }
}

-(void)didCloseUIViewController:(UMSViewControllerType)fromViewControllerType
{
    NSLog(@"didClose is %d",fromViewControllerType);
}

//下面得到分享完成的回调
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    NSLog(@"didFinishGetUMSocialDataInViewController with response is %@",response);
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}

- (IBAction)feedbackSend:(id)sender {
    //[UMFeedback showFeedback:self withAppkey:UMENG_APPKEY];
    [UMFeedback showFeedback:self withAppkey:UMENG_APPKEY dictionary:[NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:@"a", @"b", @"c", nil] forKey:@"hello"]];
}

- (IBAction)checkNewReplies:(id)sender {
    [UMFeedback checkWithAppkey:UMENG_APPKEY];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_feedbacUserfield resignFirstResponder];
    [_feedbackTextView resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

- (void)dealloc {
    _umFeedback.delegate = nil;
}

- (void)getFinishedWithError: (NSError *)error
{
    if (!error) {
        NSLog(@"getFinishedWithError : %@",error);
    }
}
- (void)postFinishedWithError:(NSError *)error
{
    if (!error) {
        NSLog(@"postFinishedWithError : %@",error);
    }
}
@end
