//
//  BEViewController.m
//  badEgg
//
//  Created by lilin on 13-10-10.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BEViewController.h"
#import "HysteriaPlayer.h"
@interface BEViewController ()

@end

@implementation BEViewController
-(void)initData{
    UIBarButtonItem* barItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.navigationItem.backBarButtonItem = barItem;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self initData];
}

- (void)dealloc {
    
}
@end
