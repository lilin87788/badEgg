//
//  BERegisterController.m
//  badEgg
//
//  Created by lilin on 13-11-13.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BERegisterController.h"

@interface BERegisterController ()

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
- (void)getPhotos
{
    UIActionSheet *photoSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选择",@"从拍摄选择", nil];
    [photoSheet showInView:self.view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
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
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 146;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //View
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 146)];
    headerView.backgroundColor = [UIColor blackColor];
    //image
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 146)];
    headerImageView.image = [UIImage imageNamed:@"picBack.png"];
    [headerView addSubview:headerImageView];
    //button
    UIButton *picButton = [UIButton buttonWithType:UIButtonTypeCustom];
    picButton.frame = CGRectMake(116, 29, 88, 88);
    [picButton setImage:[UIImage imageNamed:@"pic.png"] forState:UIControlStateNormal];
    [picButton addTarget:self action:@selector(getPhotos) forControlEvents:UIControlEventTouchDown];
    [headerView addSubview:picButton];
    return headerView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    static NSString *CellIdentifier = @"Cell";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:@"registerCell"];
    NSArray *titleArray = [NSArray arrayWithObjects:@"验 证 码:",
                           @"昵   称:",
                           @"手机号码:",
                           @"密   码:",
                           @"确认密码:", nil];
    cell.textLabel.text = [titleArray objectAtIndex:indexPath.row];
    return cell;
}


@end
