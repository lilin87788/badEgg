//
//  BEFPWController.m
//  badEgg
//
//  Created by lilin on 13-11-13.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BEFPWController.h"

@interface BEFPWController ()

@end

@implementation BEFPWController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.phoneTextfiled becomeFirstResponder];
    UIImage *leftButtonImage = [UIImage imageNamed:@"back.png"];
    UIImage *leftbuttonNormal = [leftButtonImage
                                 stretchableImageWithLeftCapWidth:10 topCapHeight:20];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame: CGRectMake(0, 0, 54, 32)];
    [leftButton setBackgroundImage:leftbuttonNormal forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(reback) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    
    UIImage *rightButtonImage = [UIImage imageNamed:@"sure.png"];
    UIImage *rightbuttonNormal = [rightButtonImage
                                  stretchableImageWithLeftCapWidth:10 topCapHeight:20];
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame: CGRectMake(0, 0, 54, 33)];
    [rightButton setBackgroundImage:rightbuttonNormal forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(goRegister) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
}

- (void)reback
{
    //返回
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goRegister
{
    //注册
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
