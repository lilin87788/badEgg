//
//  BEViewController.m
//  badEgg
//
//  Created by lilin on 13-10-10.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BEViewController.h"

@interface BEViewController ()

@end

@implementation BEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tabBar setBackgroundImage:Image(@"new")];
    self.delegate = self;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (self.selectedIndex  == 0) {
        [self.tabBar setBackgroundImage:Image(@"new")];
    }else if (self.selectedIndex  == 1){
         [self.tabBar setBackgroundImage:Image(@"list")];
    }else if (self.selectedIndex  == 2){
        [self.tabBar setBackgroundImage:Image(@"vip")];
    }else if (self.selectedIndex  == 3){
        [self.tabBar setBackgroundImage:Image(@"more")];
    }
}
@end
