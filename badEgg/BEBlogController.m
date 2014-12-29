//
//  BEBlogController.m
//  badEgg
//
//  Created by lilin on 14-3-25.
//  Copyright (c) 2014年 surekam. All rights reserved.
//

#import "BEBlogController.h"

@implementation BEBlogController
-(IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidLoad
{
    NSURL* url = [NSURL URLWithString:@"http://weibo.com/badfm?sudaref=www.baidu.com"];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [_webview loadRequest:request];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"BEBlogController"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"BEBlogController"];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
    [_activity stopAnimating];
    [_indicatorLabel setHidden:YES];
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD showWithStatus:@"加载中..."];
    //[_activity startAnimating];
    //[_indicatorLabel setHidden:NO];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD dismiss];
    [_activity stopAnimating];
    [_indicatorLabel setHidden:YES];
}
@end
