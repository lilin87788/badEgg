//
//  BEShopRecommendController.m
//  badEgg
//
//  Created by lilin on 14-3-25.
//  Copyright (c) 2014年 surekam. All rights reserved.
//

#import "BEShopRecommendController.h"

@implementation BEShopRecommendController
-(IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidLoad
{
    NSURL* url = [NSURL URLWithString:@"http://shop71800826.taobao.com/index.htm?spm=2013.1.w5002-3354594233.2.51kIfQ"];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [_webview loadRequest:request];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"BEShopRecommendController"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"BEShopRecommendController"];
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


