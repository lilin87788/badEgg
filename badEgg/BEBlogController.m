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

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_activity stopAnimating];
    [_indicatorLabel setHidden:YES];
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [_activity startAnimating];
    [_indicatorLabel setHidden:NO];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_activity stopAnimating];
    [_indicatorLabel setHidden:YES];
}
@end
