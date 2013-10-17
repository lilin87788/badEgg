//
//  BENewsController.m
//  badEgg
//
//  Created by lilin on 13-10-12.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BENewsController.h"

@interface BENewsController ()

@end

@implementation BENewsController
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)initNavBar
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationItem.backBarButtonItem.title = @"返回";
    UIImage* navbgImage;
    if (System_Version_Small_Than_(7)) {
        navbgImage = [UIImage imageNamed:@"navbar44"] ;
        self.navigationController.navigationBar.tintColor = COLOR(0, 97, 194);
//        CGRect rect = _bgScrollView.frame;
//        rect.size.height+=48;
//        [_bgScrollView setFrame:rect];
    }else{
        //[self setNeedsStatusBarAppearanceUpdate];
        navbgImage = [UIImage imageNamed:@"navibar"] ;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    [_bgScrollView setContentSize:CGSizeMake(960, _bgScrollView.frame.size.height)];
    //[self.navigationController.navigationBar setBackgroundImage:navbgImage  forBarMetrics:UIBarMetricsDefault];
    //self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor: [UIColor whiteColor]};
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self initNavBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"%@",_bgScrollView);
    
    //[self initNavBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
