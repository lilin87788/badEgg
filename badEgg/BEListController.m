//
//  BEListController.m
//  badEgg
//
//  Created by lilin on 13-11-13.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BEListController.h"
#import "BEListCell.h"
#import "BEPlayerController.h"
#import "UIColor+FlatUI.h"
#import "BEAlbum.h"
#import "BEAlbumItem.h"
#import "MJRefresh.h"
//#define DARK_BACKGROUND  [UIColor colorWithRed:151.0/255.0 green:152.0/255.0 blue:155.0/255.0 alpha:1.0]
//#define LIGHT_BACKGROUND [UIColor colorWithRed:172.0/255.0 green:173.0/255.0 blue:175.0/255.0 alpha:1.0]

@interface BEListController ()
{
    NSMutableArray* contentList;
    TFHpple *xpathParser;
    NSArray *elements;
    MJRefreshFooterView *_footer;
    NSInteger curPage;
    NSInteger totalPages;
}
@end

@implementation BEListController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
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
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    }
    [self.navigationController.navigationBar setBackgroundImage:navbgImage  forBarMetrics:UIBarMetricsDefault];

    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] init];
    [backItem setBackButtonBackgroundImage:[Image(@"back") resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 13)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    backItem.title = @"     ";
    self.navigationItem.backBarButtonItem = backItem;
}

-(void)BEFMDataFromServer
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if (curPage <= totalPages) {
        [manager GET:BADEGGFMDATA_PAGE((long)curPage) parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            BEAlbum* album = [[BEAlbum alloc] initWithDictionary:responseObject];
            totalPages = album.totalPage.intValue;
            [contentList addObjectsFromArray:album.albumItem];
            [self.tableView reloadData];
            if ([_footer isRefreshing]) {
                [_footer endRefreshing];
            }
            curPage+=1;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }else{
        if ([_footer isRefreshing]) {
            [_footer endRefreshing];
        }
    }
}

- (void)loadMoreButtonPressed:(id)sender
{
    //[self addItems];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNavBar];
    curPage = 1;
    totalPages = 1;
    contentList = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self BEFMDataFromServer];
    });
    contentList = [NSMutableArray array];
    UIRefreshControl* refreshcontrol = [[UIRefreshControl alloc]init];
    refreshcontrol.tintColor = COLOR(17, 168, 171);
    refreshcontrol.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
    [refreshcontrol addTarget:self action:@selector(RefreshViewControlEventValueChanged)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshcontrol;
    
//    UIButton *loadMoreButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    loadMoreButton.frame = CGRectMake(40, 7, 240, 44);
//    loadMoreButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//    [loadMoreButton setTitle:@"Load more" forState:UIControlStateNormal];
//    [loadMoreButton addTarget:self action:@selector(loadMoreButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    
//    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 58)];
//    [self.tableView.tableFooterView addSubview:loadMoreButton];
    
    __weak BEListController* vc = self;
    _footer = [MJRefreshFooterView footer];
    _footer.scrollView = self.tableView;
    _footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [vc BEFMDataFromServer];
    };
}

- (void)reloadDeals
{
    [_footer endRefreshing];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    if ([segue.identifier isEqualToString:@"player"])
	{
        BEAlbumItem *item = contentList[[self.tableView indexPathForSelectedRow].row - 1];
        //如果此时正在播放
        if ([[BEPlayerController sharedAudio] rate] != 0) {
            BEAlbumItem* curentItem = (BEAlbumItem*)[[BEPlayerController sharedAudio] currentItem];
            if (curentItem.proId.intValue != item.proId.intValue) {
                [[BEPlayerController sharedAudio] pause];
                [[BEPlayerController sharedAudio] removeAllItems];
                BEPlayerController *playerController = segue.destinationViewController;
                playerController.FMUrl = item.audioPathHttp;
                playerController.albumItems = [contentList subarrayWithRange:NSMakeRange([self.tableView indexPathForSelectedRow].row - 1, contentList.count  - [self.tableView indexPathForSelectedRow].row + 1)];
            }else{
                //界面显示正在播放的信息 包括点击正在播放的按钮
            }
        }else{//如果此时没有播放
            BEPlayerController *playerController = segue.destinationViewController;
            playerController.FMUrl = item.audioPathHttp;
            playerController.albumItems = [contentList subarrayWithRange:NSMakeRange([self.tableView indexPathForSelectedRow].row - 1, contentList.count  - [self.tableView indexPathForSelectedRow].row + 1)];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return contentList.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *CellIdentifier = @"introduce";
        UITableViewCell *cell;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        }else {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        }
        return cell;
    }else{
        static NSString *CellIdentifier = @"Cell";
        BEListCell *cell;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        }else {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        }
        cell.useDarkBackground = (indexPath.row % 2 == 0);
        [cell setRadioItems:contentList[indexPath.row-1]];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row) {
        cell.backgroundColor = ((BEListCell *)cell).useDarkBackground ? [UIColor DARK_BACKGROUND] : [UIColor LIGHT_BACKGROUND];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 120.;
    }
    return 75.;
}
@end
