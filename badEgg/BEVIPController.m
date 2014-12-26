//
//  BEVIPController.m
//  badEgg
//
//  Created by lilin on 13-11-13.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BEVIPController.h"
#import "UIColor+FlatUI.h"
#import "BELoginController.h"
#import "AFURLSessionManager.h"
#import "BEURLRequest.h"
#import "HysteriaPlayer.h"
#import "BEPlayerController.h"
@interface BEVIPController ()
{
    NSMutableArray* contentList;
}
@end

@implementation BEVIPController

-(void)BEFMDataFromDataBase
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString* sql = @"SELECT a.*,(CASE WHEN b.proId NOT NULL THEN 1 ELSE 0 END) AS downloaded\
        FROM T_BADEGGALBUMS a\
        JOIN T_BADEGGDOWNLOAD b\
        ON a.proId = b.proId order by publishTime desc";
        NSArray* array = [[DBQueue sharedbQueue] recordFromTableBySQL:sql];
        for (NSDictionary*dict in array) {
            BEAlbumItem* item = [[BEAlbumItem alloc] initWithAlbumItem:dict];
            [contentList addObject:item];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    contentList = [NSMutableArray array];
    [self.tableView setBackgroundColor:COLOR(230, 230, 230)];
    [self BEFMDataFromDataBase];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"BEVIPController.h"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"BEVIPController.h"];
}

#pragma mark - Table view data source

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return contentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BEAlbumItem* item = contentList[indexPath.row];
    static NSString *CellIdentifier = @"Cell";
    BEListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setRadioItems:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = (indexPath.row % 2 == 0) ? [UIColor DARK_BACKGROUND] : [UIColor LIGHT_BACKGROUND];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75.;
}
@end
