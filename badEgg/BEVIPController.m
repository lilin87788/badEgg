//
//  BEVIPController.m
//  badEgg
//
//  Created by lilin on 13-11-13.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BEVIPController.h"
#import "BEListCell.h"
#import "UIColor+FlatUI.h"
#import "BELoginController.h"
//#define DARK_BACKGROUND  [UIColor colorWithRed:151.0/255.0 green:152.0/255.0 blue:155.0/255.0 alpha:1.0]
//#define LIGHT_BACKGROUND [UIColor colorWithRed:172.0/255.0 green:173.0/255.0 blue:175.0/255.0 alpha:1.0]

@interface BEVIPController ()
{
    NSArray* contentList;
}
@end

@implementation BEVIPController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) handleData
{
    [self.refreshControl endRefreshing];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
    [self.tableView reloadData];
}

-(void)RefreshViewControlEventValueChanged
{
    if (self.refreshControl.refreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"刷新中"];
        [self performSelector:@selector(handleData) withObject:nil afterDelay:2];
    }
}

-(void)initNavBar
{
    self.navigationItem.backBarButtonItem.title = @"返回";
    UIImage* navbgImage;
    if (System_Version_Small_Than_(7)) {
        navbgImage = [UIImage imageNamed:@"navbar44"];
    }else{
        navbgImage = [UIImage imageNamed:@"navbar64"] ;
    }
    [self.navigationController.navigationBar setBackgroundImage:navbgImage  forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNavBar];
    contentList = @[@"五一通州的坏体验",@"明星与我苏中场",@"问题少年的春天",@"再说手机号",@"开车有妞不听歌",@"说说唐朝这些年",@"我爱看AV",@"永远爱苍老师"];
    UIRefreshControl* refreshcontrol = [[UIRefreshControl alloc]init];
    refreshcontrol.tintColor = COLOR(17, 168, 171);
    refreshcontrol.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
    [refreshcontrol addTarget:self action:@selector(RefreshViewControlEventValueChanged)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshcontrol;
    if (1) {
//        BELoginController* loginer = [[APPUtils AppStoryBoard] instantiateViewControllerWithIdentifier:@"BELogin"];
//        [self addChildViewController:loginer];
//        [self.view addSubview:loginer.view];
//        [self performSegueWithIdentifier:@"aaa" sender:self];
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return contentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        static NSString *CellIdentifier = @"Cell";
        BEListCell *cell;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        }else {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        }
        cell.useDarkBackground = (indexPath.row % 2 == 0);
        //[cell setRadioItems:contentList[indexPath.row]];
        return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = ((BEListCell *)cell).useDarkBackground ? [UIColor DARK_BACKGROUND] : [UIColor LIGHT_BACKGROUND];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 75.;
}
@end
