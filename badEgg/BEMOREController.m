//
//  BEMOREController.m
//  badEgg
//
//  Created by lilin on 13-11-13.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BEMOREController.h"
#import "SKPlaceholderTextView.h"
#import "BEIntroController.h"
#import "BEFeedBackController.h"
#import "UIColor+FlatUI.h"
#import "SKPathButton.h"
@interface BEMOREController ()
@property (weak, nonatomic) IBOutlet SKPlaceholderTextView *feedbackTextView;
@property (weak, nonatomic) IBOutlet UITextField *feedbacUserfield;

@property (weak, nonatomic) IBOutlet UIImageView *personBgImageView;
@property (weak, nonatomic) IBOutlet SKPathButton *personHeadButton;
@end

@implementation BEMOREController


-(void)initData
{
//    _umFeedback = [UMFeedback sharedInstance];
//    [_umFeedback setAppkey:UMENG_APPKEY delegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"] ];
    self.tableView.tableHeaderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"introduce.png"]];
    
//    self.tableView.tableHeaderView = ({
//        UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 1, SCREEN_WIDTH, 139)];
//        CGRect rect = bgView.bounds;
//        rect.origin.y = 20;
//        rect.size.height -= 20;
//        
//        UIImage * bgImage = [UIImage imageNamed:@"cm_u_block"];
//        bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, bgImage.size.width - 15, 0,5)];
//        
//        UIImageView* bgImageView = [[UIImageView alloc] initWithFrame:rect];
////        bgImageView.layer.borderColor = [UIColor LIGHT_BACKGROUND].CGColor;
////        bgImageView.layer.borderWidth = 1;
//        bgImageView.image = bgImage;
//        [bgView addSubview:bgImageView];
//        
//        SKPathButton* headButton = [[SKPathButton alloc] initWithFrame:CGRectMake(31, 10, 80, 80) image:[UIImage imageNamed:@"cm_default_head_80"] pathType:GBPathButtonTypeCircle pathColor:[UIColor whiteColor] borderColor:[UIColor LIGHT_BACKGROUND] pathWidth:6];
//        [bgView addSubview:headButton];
//        bgView;
//    });
    
    [_feedbackTextView setPlaceholder:@"请您输入宝贵的意见:"];
    [_feedbackTextView setPlaceholderColor:COLOR(150, 150, 150)];
    [_feedbackTextView setTextColor:COLOR(150, 150, 150)];
    [_feedbackTextView.layer setCornerRadius:4];
    [_feedbacUserfield setTextColor:COLOR(150, 150, 150)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"BEMOREController.h"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"BEMOREController.h"];
}

- (IBAction)badEggIntroduction:(id)sender {
    [self setHidesBottomBarWhenPushed:YES];
    BEIntroController* playerController = [[BEIntroController alloc] initWithNibName:@"BEIntroController" bundle:nil];
    [self.navigationController pushViewController:playerController animated:YES];
    [self setHidesBottomBarWhenPushed:NO];
}

-(IBAction)showShareList:(id)sender
{
     [MobClick event:@"展示分享界面"];
    //NSString *shareText = @"友盟社会化组件可以让移动应用快速具备社会化分享、登录、评论、喜欢等功能，并提供实时、全面的社会化数据统计分析服务。 http://www.umeng.com/social";             //分享内嵌文字
   // UIImage *shareImage = [UIImage imageNamed:@"UMS_social_demo"];          //分享内嵌图片
    
    //如果得到分享完成回调，需要设置delegate为self
   // [UMSocialSnsService presentSnsIconSheetView:self appKey:UMENG_APPKEY shareText:shareText shareImage:shareImage shareToSnsNames:nil delegate:self];
}

#pragma -mark tableViewDelegate
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor DARK_BACKGROUND];
   //cell.backgroundColor = indexPath.row % 2 == 0 ? [UIColor DARK_BACKGROUND] : [UIColor LIGHT_BACKGROUND];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 1:
        {
            if (indexPath.row == 0) {
                [self setHidesBottomBarWhenPushed:YES];
               // UIViewController* feedBackController = [UMFeedback feedbackViewController];
                BEFeedBackController*  feedBackController = [[BEFeedBackController alloc] initWithNibName:@"BEFeedBackController" bundle:nil];
                [self.navigationController pushViewController:feedBackController
                                                     animated:YES];
                [self setHidesBottomBarWhenPushed:NO];
            }
            break;
        }
        case 2:
            
        {
            if (indexPath.row == 0) {
                
            }
            break;
        }
            
        default:
            break;
    }
}

//-(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
//{
//    if ([platformName isEqualToString:UMShareToSina]) {
//        socialData.shareText = @"分享到新浪微博";
//    }
//    else{
//        socialData.shareText = @"分享内嵌文字";
//    }
//}

//-(void)didCloseUIViewController:(UMSViewControllerType)fromViewControllerType
//{
//    NSLog(@"didClose is %d",fromViewControllerType);
//}
//
////下面得到分享完成的回调
//-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
//{
//    NSLog(@"didFinishGetUMSocialDataInViewController with response is %@",response);
//    //根据`responseCode`得到发送结果,如果分享成功
//    if(response.responseCode == UMSResponseCodeSuccess)
//    {
//        //得到分享到的微博平台名
//        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
//    }
//}

- (IBAction)feedbackSend:(id)sender {
    //[UMFeedback showFeedback:self withAppkey:UMENG_APPKEY];
    //[UMFeedback showFeedback:self withAppkey:UMENG_APPKEY dictionary:[NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:@"a", @"b", @"c", nil] forKey:@"hello"]];
}

- (IBAction)checkNewReplies:(id)sender {
    //[UMFeedback checkWithAppkey:UMENG_APPKEY];
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
   // _umFeedback.delegate = nil;
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
