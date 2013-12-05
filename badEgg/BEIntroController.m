//
//  BEIntroController.m
//  badEgg
//
//  Created by lilin on 13-11-13.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BEIntroController.h"

@interface BEIntroController ()
@property (weak, nonatomic) IBOutlet UIImageView *introImageView;

@end

@implementation BEIntroController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _introImageView.image = Image(@"intro_4-568h");

    if (IS_IPHONE_5) {
        _introImageView.image = Image(@"intro_5");
    }else{
            Image(@"intro_4");
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
