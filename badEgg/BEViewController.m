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
-(void)initNaviItem{
    UIBarButtonItem* barItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.navigationItem.backBarButtonItem = barItem;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self initNaviItem];
}

- (void)dealloc {
    
}
@end
