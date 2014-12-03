//
//  BEBlogController.h
//  badEgg
//
//  Created by lilin on 14-3-25.
//  Copyright (c) 2014年 surekam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BEBlogController : UIViewController
<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UILabel *indicatorLabel;

@end
