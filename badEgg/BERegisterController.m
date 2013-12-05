//
//  BERegisterController.m
//  badEgg
//
//  Created by lilin on 13-11-13.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BERegisterController.h"

@interface BERegisterController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation BERegisterController

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
    UIImage *leftButtonImage = [UIImage imageNamed:@"back.png"];
    UIImage *leftbuttonNormal = [leftButtonImage
                                 stretchableImageWithLeftCapWidth:10 topCapHeight:20];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame: CGRectMake(0, 0, 54, 32)];
    [leftButton setBackgroundImage:leftbuttonNormal forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(reback) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
//    
//    UIImage *rightButtonImage = [UIImage imageNamed:@"sure.png"];
//    UIImage *rightbuttonNormal = [rightButtonImage
//                                  stretchableImageWithLeftCapWidth:10 topCapHeight:20];
//    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightButton setFrame: CGRectMake(0, 0, 54, 33)];
//    [rightButton setBackgroundImage:rightbuttonNormal forState:UIControlStateNormal];
//    [rightButton addTarget:self action:@selector(goRegister) forControlEvents:UIControlEventTouchDown];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
}

- (void)reback
{
    //返回
    [self dismissViewControllerAnimated:YES completion:^{
    
    }];
}
- (void)goRegister
{
    //注册
}

-(void)initNavBar
{
    self.navigationItem.backBarButtonItem.title = @"返回";
    UIImage* navbgImage;
    if (System_Version_Small_Than_(7)) {
        navbgImage = [UIImage imageNamed:@"navi"];
    }else{
        navbgImage = [UIImage imageNamed:@"navi5"] ;
    }
    [self.navigationController.navigationBar setBackgroundImage:navbgImage  forBarMetrics:UIBarMetricsDefault];
}


- (void)getPhotos
{
    UIActionSheet *photoSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选择",@"从拍摄选择", nil];
    [photoSheet showInView:self.view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //_tableview.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    _tableview.layer.cornerRadius=6;
    _tableview.layer.masksToBounds=YES;
    [self initNavBar];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    static NSString *CellIdentifier = @"Cell";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"registerCell%d",indexPath.row]];

    return cell;
}


@end
