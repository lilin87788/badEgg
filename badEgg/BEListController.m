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
#import "HysteriaPlayer.h"
#import "AFURLSessionManager.h"
#import "UIProgressView+AFNetworking.h"
#import "AFHTTPRequestOperationManager.h"

@interface BEListController ()
{
    NSMutableArray* contentList;
    TFHpple *xpathParser;
    NSArray *elements;
    NSInteger curPage;
    NSInteger totalPages;
    NSString* maxPublishTime;
}
@property MJRefreshFooterView *footer;
@end

@implementation BEListController
//下拉刷新
-(void)RefreshViewControlEventValueChanged
{
    if (self.refreshControl.refreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"刷新中"];
        curPage = 1;
        [self BERefreshFMDataFromServer:^{
            maxPublishTime = [[DBQueue sharedbQueue] maxPublishTime];
            [contentList removeAllObjects];
            [self BEFMDataFromDataBase:^{
                [self.tableView reloadData];
                [self.refreshControl endRefreshing];
                self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
            }];
        }];
    }
}

//非首次更新数据
-(void)BERefreshFMDataFromServer:(BEBaseCompleteBlock)block
{
    [[BEHttpRequest sharedClient] requestFMDataWithPageNo:curPage responseBlock:^(BOOL isOK, BEAlbum *album, NSError *error) {
        if (isOK) {
            totalPages = album.totalPage.intValue;
            curPage++;
            NSString* minpublishTime =[(BEAlbumItem*)album.albumItem.lastObject publishTime];
            NSString* maxServerPublishTime =[(BEAlbumItem*)album.albumItem[0] publishTime];
            if (maxServerPublishTime == maxPublishTime) {//服务端的时间只可能大于或者等于本地的时间
                //如果从服务端拿过来的数据最小的时间仍然比本地的最大的时间要大，说明很久没有更新过了，还需要继续从服务端拿数据
                if (minpublishTime.intValue > maxPublishTime.intValue) {
                    [self BERefreshFMDataFromServer:block];
                }else {
                    maxPublishTime = [(BEAlbumItem*)album.albumItem[0] publishTime];
                    if (block) {
                        block();
                    }
                }
            }
        }else{
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

//首次更新数据
-(void)BEFirstFMDataFromServer:(BEBaseCompleteBlock)block
{
    [[BEHttpRequest sharedClient] requestFMDataWithPageNo:curPage responseBlock:^(BOOL isOK, BEAlbum *album, NSError *error) {
        if (isOK) {
            [SVProgressHUD showProgress:curPage/(float)totalPages status:@"努力加载中..." maskType:SVProgressHUDMaskTypeClear];
            totalPages = album.totalPage.intValue;
            curPage++;
            
            if (curPage <= totalPages) {
                [self BEFirstFMDataFromServer:block];
            } else{
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"haveSynedBEFMData"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                maxPublishTime = [[DBQueue sharedbQueue] maxPublishTime];
                [SVProgressHUD dismiss];
                if (block) {
                    block();
                }
            }
        }else{
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

-(void)BEFMDataFromDataBase:(BEBaseCompleteBlock)block
{
    
    NSString* sql = [NSString stringWithFormat:@"SELECT a.*,(CASE WHEN b.proId NOT NULL THEN 1 ELSE 0 END) AS downloaded\
                     FROM T_BADEGGALBUMS a\
                     LEFT JOIN T_BADEGGDOWNLOAD b\
                     ON a.proId = b.proId order by publishTime desc limit %lu,15",(unsigned long)contentList.count];
    NSArray* array = [[DBQueue sharedbQueue] recordFromTableBySQL:sql];
    for (NSDictionary*dict in array) {
        BEAlbumItem* item = [[BEAlbumItem alloc] initWithAlbumItem:dict];
        [contentList addObject:item];
    }
    if (block) {
        block();
    }
}

- (IBAction)playingAlbumItem:(UIButton *)sender {
    BEPlayerController* playerController = [[BEPlayerController alloc] initWithNibName:@"BEPlayerController" bundle:nil];
    playerController.isClickPlaingBtn = YES;
    [self.navigationController pushViewController:playerController animated:YES];
    [self setHidesBottomBarWhenPushed:NO];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        curPage = 1;
        totalPages = 1;
        contentList = [NSMutableArray array];
    }
    return self;
}

-(void)dealloc
{
    contentList = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    maxPublishTime = [[DBQueue sharedbQueue] maxPublishTime];

    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"] ];
    self.tableView.tableHeaderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"introduce.png"]];
//    [[BEHttpRequest sharedClient] requestFMDataWithPageNo:curPage responseBlock:^(BOOL isOK, BEAlbum *album, NSError *error) {
//        if(isOK){
//            [contentList addObjectsFromArray:album.albumItem];
//            curPage++;
//            [self.tableView reloadData];
//        }else{
//        
//        }
//    }];
//    

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString* sql = [NSString stringWithFormat:@"SELECT a.*,(CASE WHEN b.proId NOT NULL THEN 1 ELSE 0 END) AS downloaded\
                        FROM T_BADEGGALBUMS a\
                        LEFT JOIN T_BADEGGDOWNLOAD b\
                        ON a.proId = b.proId order by publishTime desc limit %lu,15",(unsigned long)contentList.count];
        NSArray* array = [[DBQueue sharedbQueue] recordFromTableBySQL:sql];
        for (NSDictionary*dict in array) {
            BEAlbumItem* item = [[BEAlbumItem alloc] initWithAlbumItem:dict];
            [contentList addObject:item];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"haveSynedBEFMData"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self BERefreshFMDataFromServer:^{
                [contentList removeAllObjects];
                [self BEFMDataFromDataBase:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshCompleted" object:0];
                    [self.tableView reloadData];
                }];
            }];
        });
    }else{
        [self BEFirstFMDataFromServer:^{
            [self BEFMDataFromDataBase:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshCompleted" object:0];
                [self.tableView reloadData];
            }];
        }];
    }
    
    __unsafe_unretained BEListController* vc1 = self;
    _footer = [MJRefreshFooterView footer];
    _footer.scrollView = self.tableView;
    _footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [vc1 BEFMDataFromDataBase:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [vc1.tableView reloadData];
                [vc1.footer endRefreshing];
            });
        }];
    };
    
//    return;
//    {
//        maxPublishTime = [[DBQueue sharedbQueue] maxPublishTime];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//            [self BEFMDataFromDataBase:^{
//                [self.tableView reloadData];
//                HysteriaPlayer* beplayer = [HysteriaPlayer sharedInstance];
//                [beplayer setupSourceGetter:^BEAlbumItem *(NSUInteger index){
//                    return contentList[index];
//                } ItemsCount:contentList.count];
//                
//                
//                
//                
//                if([[NSUserDefaults standardUserDefaults] boolForKey:@"firstRefreshData"] == NO){
//                    [self BEFirstFMDataFromServer:^{
//                        [self BEFMDataFromDataBase:^{
//                            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshCompleted" object:0];
//                            maxPublishTime = [[DBQueue sharedbQueue]  maxPublishTime];
//                            HysteriaPlayer* beplayer = [HysteriaPlayer sharedInstance];
//                            [beplayer setupSourceGetter:^BEAlbumItem *(NSUInteger index){
//                                return contentList[index];
//                            } ItemsCount:contentList.count];
//                            [self.tableView reloadData];
//                        }];
//                    }];
//                }else{
//                    [self BERefreshFMDataFromServer:^{
//                        maxPublishTime = [[DBQueue sharedbQueue] maxPublishTime];
//                        [contentList removeAllObjects];
//                        [self BEFMDataFromDataBase:^{
//                            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshCompleted" object:0];
//                            HysteriaPlayer* beplayer = [HysteriaPlayer sharedInstance];
//                            [beplayer setupSourceGetter:^BEAlbumItem *(NSUInteger index){
//                                return contentList[index];
//                            } ItemsCount:contentList.count];
//                            [self.tableView reloadData];
//                        }];
//                    }];
//                }
//            }];
//        });
//        
//        UIRefreshControl* refreshcontrol = [[UIRefreshControl alloc]init];
//        refreshcontrol.tintColor = COLOR(17, 168, 171);
//        refreshcontrol.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
////        [refreshcontrol addTarget:self action:@selector(RefreshViewControlEventValueChanged)
////                 forControlEvents:UIControlEventValueChanged];
////        self.refreshControl = refreshcontrol;
////        [self.refreshControl setRefreshingWithStateOfTask:<#(NSURLSessionTask *)#>]
//        
//        __unsafe_unretained BEListController* vc = self;
//        _footer = [MJRefreshFooterView footer];
//        _footer.scrollView = self.tableView;
//        _footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
//            [vc BEFMDataFromDataBase:^{
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [vc.tableView reloadData];
//                    if ([vc.footer isRefreshing]) {
//                        [vc.footer endRefreshing];
//                    }
//                });
//            }];
//        };
//    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"BEListController"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"BEListController"];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"player"])
	{
        HysteriaPlayer* beplayer = [HysteriaPlayer sharedInstance];
        [beplayer setupSourceGetter:^BEAlbumItem *(NSUInteger index){
            return contentList[index];
        } ItemsCount:contentList.count];
        [beplayer removeAllItems];
        BEPlayerController *playerController = segue.destinationViewController;
        playerController.currentItems = contentList[[self.tableView indexPathForSelectedRow].row-1];
        playerController.currentIndex = [self.tableView indexPathForSelectedRow].row-1;
        playerController.isClickPlaingBtn = NO;
    }
    
    if ([segue.identifier isEqualToString:@"playing"])
	{
        HysteriaPlayer *player = [HysteriaPlayer sharedInstance];
         NSUInteger index = [[player getHysteriaOrder:[player getCurrentItem]] unsignedIntegerValue];
        BEPlayerController *playerController = segue.destinationViewController;
        playerController.currentIndex = index;
        playerController.isClickPlaingBtn = YES;
    }
}


#pragma mark - Table view data source
- (IBAction)downloadRadio:(UIButton *)sender {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    BEListCell* cell = (BEListCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    BEAlbumItem* albumItem = contentList[sender.tag];
    
    [cell.taskProgressView setHidden:NO];
    NSString* url = [NSString stringWithString:albumItem.virtualAddress];
    AFURLSessionManager* manager = [BEHttpRequest sharedClient];
    NSURL *URL = [NSURL URLWithString:[url stringByAppendingString:@"?dow=true"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDownloadTask *downloadTask =
    [manager downloadTaskWithRequest:request
                            progress:nil
                         destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                             return [NSURL fileURLWithPath:[[HNFileManager defaultManager] albumPathWithProId:albumItem.proId]];
                         }
                   completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                       albumItem.downloadTask = nil;
                       albumItem.downloaded = YES;
                       [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                       [[DBQueue sharedbQueue] downloadCompleteWithAlbumItem:albumItem];
                   }];
    [downloadTask resume];
    
    albumItem.downloadTask = downloadTask;
    [cell.taskProgressView setProgressWithDownloadProgressOfTask:downloadTask animated:YES];
    [cell.downloadBtn setEnabled:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return contentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BEAlbumItem* item = contentList[indexPath.row];
    static NSString *CellIdentifier = @"Cell";
    BEListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell.downloadBtn addTarget:self action:@selector(downloadRadio:) forControlEvents:UIControlEventTouchUpInside];
    [cell.downloadBtn setTag:indexPath.row];
    //cell.useDarkBackground = (indexPath.row % 2 == 0);
    [cell setRadioItems:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
   cell.backgroundColor = (indexPath.row % 2 == 0) ? [UIColor DARK_BACKGROUND] : [UIColor LIGHT_BACKGROUND];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HysteriaPlayer* beplayer = [HysteriaPlayer sharedInstance];
    [beplayer removeAllItems];
    [beplayer setupSourceGetter:^BEAlbumItem *(NSUInteger index){
        return contentList[index];
    } ItemsCount:contentList.count];
    
    [self setHidesBottomBarWhenPushed:YES];
    BEPlayerController* playerController = [[BEPlayerController alloc] initWithNibName:@"BEPlayerController" bundle:nil];
    playerController.currentItems = contentList[indexPath.row];
    playerController.currentIndex = indexPath.row;
    playerController.isClickPlaingBtn = NO;
    [self.navigationController pushViewController:playerController animated:YES];
    [self setHidesBottomBarWhenPushed:NO];
}
@end
