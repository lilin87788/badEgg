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
}
@end

@implementation BEVIPController
+(NSMutableArray*)sharedVIPContentList{
    static NSMutableArray* array = nil;
    static dispatch_once_t onceToken; dispatch_once(&onceToken, ^{
        array = [[NSMutableArray alloc] init];
    });
    return array;
}

-(void)BEFMDataFromDataBase:(BEBaseCompleteBlock)block
{
    NSMutableArray* contentList = [BEVIPController sharedVIPContentList];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString* sql = [NSString stringWithFormat:@"select * from T_BADEGGALBUMS where dowStatus = 2 order by publishTime desc"];
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
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    cellNib = [UINib nibWithNibName:@"BEMyAlbumCell" bundle:nil];
    [self.tableView setBackgroundColor:COLOR(230, 230, 230)];
    [self BEFMDataFromDataBase:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"addDownloadTask" object:0 queue:0 usingBlock:^(NSNotification* note){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
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
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    if ([segue.identifier isEqualToString:@"player"])
	{
        HysteriaPlayer* beplayer = [HysteriaPlayer sharedInstance];
        [beplayer setupSourceGetter:^BEAlbumItem *(NSUInteger index){
            return [BEVIPController sharedVIPContentList][index];
        } ItemsCount:[BEVIPController sharedVIPContentList].count];
        [beplayer removeAllItems];
        BEPlayerController *playerController = segue.destinationViewController;
        playerController.currentItems = [BEVIPController sharedVIPContentList][[self.tableView indexPathForSelectedRow].row];
        playerController.currentIndex = [self.tableView indexPathForSelectedRow].row;
        playerController.isClickPlaingBtn = NO;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"player" sender:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray* contentList = [BEVIPController sharedVIPContentList];
    return contentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *EIdentifier = @"vipcell";
//    BEMyAlbumCell *cell = (BEMyAlbumCell *)[tableView dequeueReusableCellWithIdentifier:EIdentifier];
//    if (!cell) {
//        [cellNib instantiateWithOwner:self options:nil];
//        cell = _albumCell;_albumCell = nil;
//    }
//    cell.useDarkBackground = (indexPath.row % 2 == 0);
//    [cell setRadioItems:contentList[indexPath.row]];
//    return cell;
    
    NSMutableArray* contentList = [BEVIPController sharedVIPContentList];
    [cellNib instantiateWithOwner:self options:nil];
    BEMyAlbumCell *cell = _albumCell;_albumCell = nil;
    cell.useDarkBackground = (indexPath.row % 2 == 0);
    [cell setRadioItems:contentList[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = ((BEMyAlbumCell *)cell).useDarkBackground ? [UIColor DARK_BACKGROUND] : [UIColor LIGHT_BACKGROUND];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75.;
}
@end
