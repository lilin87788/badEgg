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
- (void) handleData
{
    curPage = 1;
    [self BERefreshFMDataFromServer:^{
        maxPublishTime = [self maxPublishTime];
        [contentList removeAllObjects];
        [self BEFMDataFromDataBase:^{
            HysteriaPlayer* beplayer = [HysteriaPlayer sharedInstance];
            [beplayer setupSourceGetter:^BEAlbumItem *(NSUInteger index){
                return contentList[index];
            } ItemsCount:contentList.count];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.refreshControl endRefreshing];
                self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
            });
        }];
    }];
}

-(void)RefreshViewControlEventValueChanged
{
    if (self.refreshControl.refreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"刷新中"];
        [self handleData];
    }
}

-(void)BERefreshFMDataFromServer:(BEBaseCompleteBlock)block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:BADEGGFMDATA_PAGE((long)curPage) parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BEAlbum* album = [[BEAlbum alloc] initWithDictionary:responseObject];
        totalPages = album.totalPage.intValue;
        [[DBQueue sharedbQueue] insertDataToLocalDataBaseWithAlbum:album completeBlock:^{}];
        NSString* minpublishTime =[(BEAlbumItem*)album.albumItem.lastObject publishTime];
        curPage++;
        if (minpublishTime.intValue >= maxPublishTime.intValue) {
            [self BERefreshFMDataFromServer:block];
        }
        if (minpublishTime.intValue <  maxPublishTime.intValue) {
            if (block) {
                block();
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)BEFirstFMDataFromServer:(BEBaseCompleteBlock)block
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:BADEGGFMDATA_PAGE((long)curPage) parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BEAlbum* album = [[BEAlbum alloc] initWithDictionary:responseObject];
        totalPages = album.totalPage.intValue;
        [[DBQueue sharedbQueue] insertDataToLocalDataBaseWithAlbum:album completeBlock:^{}];
        curPage++;
        if (curPage <= totalPages) {
            [self BEFirstFMDataFromServer:block];
        }
        if (curPage > totalPages) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstRefreshData"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if (block) {
                block();
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)loadMoreButtonPressed:(id)sender
{
    [self.tableView reloadData];
}

-(void)BEFMDataFromDataBase:(BEBaseCompleteBlock)block
{
    NSString* sql = [NSString stringWithFormat:@"select * from T_BADEGGALBUMS order by publishTime desc limit %lu,15",(unsigned long)contentList.count];
    NSArray* array = [[DBQueue sharedbQueue] recordFromTableBySQL:sql];
    for (NSDictionary*dict in array) {
        BEAlbumItem* item = [[BEAlbumItem alloc] initWithURL:[NSURL URLWithString:dict[@"audioPathHttp"]]];
        item.proName = dict[@"proName"];
        item.fileName = dict[@"fileName"];
        item.proTags = dict[@"proTags"];
        item.proIntro = dict[@"proIntro"];
        item.proIntroDto = dict[@"proIntroDto"];
        item.proIntroToSubString = dict[@"proIntroToSubString"];
        
        item.audioPathHttp = dict[@"audioPathHttp"];
        item.audioPath = dict[@"audioPath"];
        item.virtualAddress = dict[@"virtualAddress"];
        item.virtualAddressOld = dict[@"virtualAddressOld"];
        
        item.createTime = dict[@"createTime"];
        item.updateTime = dict[@"updateTime"];
        item.publishTime = dict[@"publishTime"];
        item.playTime = dict[@"playTime"];
        
        item.proAlbumId = dict[@"proAlbumId"];
        item.proCreater = dict[@"proCreater"];
        item.listenNum = dict[@"listenNum"];
        item.proId = dict[@"proId"];
        item.dowStatus = dict[@"dowStatus"];
        [contentList addObject:item];
    }
    if (block) {
        block();
    }
}

-(NSString*)maxPublishTime
{
    NSString* sql =  @"select max(publishTime) publishTime from T_BADEGGALBUMS;";
     NSString*result = [[DBQueue sharedbQueue] getSingleRowBySQL:sql][@"publishTime"];
    if ([result isEqual:[NSNull null]]) {
        return @"0";
    }else{
        return result;
    }
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
    maxPublishTime = [self maxPublishTime];

//    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"] ];
    self.tableView.tableHeaderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"introduce.png"]];
    [[BEHttpRequest sharedClient] requestFMDataWithPageNo:curPage responseBlock:^(BOOL isOK, BEAlbum *album, NSError *error) {
        [contentList addObjectsFromArray:album.albumItem];
        curPage++;
        [self.tableView reloadData];
    }];
    
    __unsafe_unretained BEListController* vc1 = self;
    _footer = [MJRefreshFooterView footer];
    _footer.scrollView = self.tableView;
    _footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [[BEHttpRequest sharedClient] requestFMDataWithPageNo:vc1->curPage responseBlock:^(BOOL isOK, BEAlbum *album, NSError *error) {
            [vc1 ->contentList addObjectsFromArray:album.albumItem];
            vc1 -> curPage++;
            if ([vc1 ->_footer isRefreshing]) {
                [vc1 ->_footer endRefreshing];
            }
            [vc1.tableView reloadData];
        }];
    };
    return;
    {
        maxPublishTime = [self maxPublishTime];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self BEFMDataFromDataBase:^{
                [self.tableView reloadData];
                HysteriaPlayer* beplayer = [HysteriaPlayer sharedInstance];
                [beplayer setupSourceGetter:^BEAlbumItem *(NSUInteger index){
                    return contentList[index];
                } ItemsCount:contentList.count];
                
                
                if([[NSUserDefaults standardUserDefaults] boolForKey:@"firstRefreshData"] == NO){
                    [self BEFirstFMDataFromServer:^{
                        [self BEFMDataFromDataBase:^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshCompleted" object:0];
                            maxPublishTime = [self maxPublishTime];
                            HysteriaPlayer* beplayer = [HysteriaPlayer sharedInstance];
                            [beplayer setupSourceGetter:^BEAlbumItem *(NSUInteger index){
                                return contentList[index];
                            } ItemsCount:contentList.count];
                            [self.tableView reloadData];
                        }];
                    }];
                }else{
                    [self BERefreshFMDataFromServer:^{
                        maxPublishTime = [self maxPublishTime];
                        [contentList removeAllObjects];
                        [self BEFMDataFromDataBase:^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshCompleted" object:0];
                            HysteriaPlayer* beplayer = [HysteriaPlayer sharedInstance];
                            [beplayer setupSourceGetter:^BEAlbumItem *(NSUInteger index){
                                return contentList[index];
                            } ItemsCount:contentList.count];
                            [self.tableView reloadData];
                        }];
                    }];
                }
            }];
        });
        
        UIRefreshControl* refreshcontrol = [[UIRefreshControl alloc]init];
        refreshcontrol.tintColor = COLOR(17, 168, 171);
        refreshcontrol.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
        [refreshcontrol addTarget:self action:@selector(RefreshViewControlEventValueChanged)
                 forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshcontrol;
        
        HysteriaPlayer *bePlayer = [HysteriaPlayer sharedInstance];
        [bePlayer registerHandlerFailed:^(HysteriaPlayerFailed identifier, NSError *error){
            NSLog(@"%@",error);
        }];
        
        __unsafe_unretained BEListController* vc = self;
        _footer = [MJRefreshFooterView footer];
        _footer.scrollView = self.tableView;
        _footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
            [vc BEFMDataFromDataBase:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [vc.tableView reloadData];
                    if ([vc.footer isRefreshing]) {
                        [vc.footer endRefreshing];
                    }
                });
            }];
        };
    }
}

- (void)reloadDeals
{
    [_footer endRefreshing];
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
    //BEListCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag + 1 inSection:1]];
    //NSLog(@"%d %@",sender.tag,cell.class);
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
    cell.useDarkBackground = (indexPath.row % 2 == 0);
    [cell setRadioItems:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = ((BEListCell *)cell).useDarkBackground ? [UIColor DARK_BACKGROUND] : [UIColor LIGHT_BACKGROUND];
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
