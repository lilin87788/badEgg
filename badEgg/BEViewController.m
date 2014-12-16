//
//  BEViewController.m
//  badEgg
//
//  Created by lilin on 13-10-10.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BEViewController.h"
#import "HysteriaPlayer.h"
@interface BEViewController ()

@end

@implementation BEViewController
- (void)configNowPlayingInfoCenter:(BEAlbumItem*)currentItem
{
    if (NSClassFromString(@"MPNowPlayingInfoCenter"))
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setObject:currentItem.proName forKey:MPMediaItemPropertyTitle];
        [dict setObject:@"播客" forKey:MPMediaItemPropertyArtist];
        [dict setObject:@"坏蛋调频" forKey:MPMediaItemPropertyAlbumTitle];
        [dict setObject:[[MPMediaItemArtwork alloc] initWithImage:
                         Image(@"badegg.jpg")] forKey:MPMediaItemPropertyArtwork];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    [self.tabBar setBackgroundImage:Image(@"new")];
    self.delegate = self;
    
    HysteriaPlayer* player = [HysteriaPlayer sharedInstance];
    [player registerHandlerPlayerRateChanged:^{
        
    } CurrentItemChanged:^(BEAlbumItem* item){
        [self configNowPlayingInfoCenter:item];
    } PlayerDidReachEnd:^{
        BEAlbumItem* item = [player getCurrentItem];
        NSLog(@"PlayerDidReachEnd %@",item.proName);
    }];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (self.selectedIndex  == 0) {
        [self.tabBar setBackgroundImage:Image(@"new")];
    }else if (self.selectedIndex  == 1){
         [self.tabBar setBackgroundImage:Image(@"list")];
    }else if (self.selectedIndex  == 2){
        [self.tabBar setBackgroundImage:Image(@"my")];
    }else if (self.selectedIndex  == 3){
        [self.tabBar setBackgroundImage:Image(@"more")];
    }
}

- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    HysteriaPlayer* player = [HysteriaPlayer sharedInstance];
    if (player.items_count) {
        if (receivedEvent.type == UIEventTypeRemoteControl) {
            switch (receivedEvent.subtype) {
                case UIEventSubtypeRemoteControlTogglePlayPause:
                {
                    NSLog(@"UIEventSubtypeRemoteControlTogglePlayPause");
                    if ([player isPlaying]) {
                        [player pausePlayerForcibly:YES];
                        [player pause];
                    }else{
                        if ([player getCurrentItem]) {
                            [player play];
                        }else{
                            [player fetchAndPlayPlayerItem:0];
                        }
                    }
                    break;
                }
                case UIEventSubtypeRemoteControlPreviousTrack:
                {
                    NSLog(@"UIEventSubtypeRemoteControlPreviousTrack");
                    [player playPrevious];
                    [player play];
                    break;
                }
                case UIEventSubtypeRemoteControlNextTrack:
                {
                    NSLog(@"UIEventSubtypeRemoteControlNextTrack");
                    [player playNext];
                    [player play];
                    break;
                }
                case UIEventSubtypeRemoteControlPlay:
                {
                    NSLog(@"UIEventSubtypeRemoteControlPlay");
                    if ([player getCurrentItem]) {
                        [player play];
                    }else{
                        [player fetchAndPlayPlayerItem:0];
                    }
                    break;
                }
                case UIEventSubtypeRemoteControlPause:
                {
                    NSLog(@"UIEventSubtypeRemoteControlNextTrack");
                    [player pausePlayerForcibly:YES];
                    [player pause];
                    break;
                }
                default:
                {
                    break;
                }
            }
        }
    }
}


-(void)initData
{
//    _umFeedback = [UMFeedback sharedInstance];
//    [_umFeedback setAppkey:UMENG_APPKEY delegate:self];
}

- (void)feedbackSend{
    //[UMFeedback showFeedback:self withAppkey:UMENG_APPKEY];
    //[UMFeedback showFeedback:self withAppkey:UMENG_APPKEY dictionary:[NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:@"a", @"b", @"c", nil] forKey:@"hello"]];
}

- (void)getFinishedWithError: (NSError *)error
{
    if (!error) {
        NSLog(@"getFinishedWithError : %@",error);
    }
}
- (void)postFinishedWithError:(NSError *)error
{
    if (!error) {
        NSLog(@"postFinishedWithError : %@",error);
    }
}

- (void)dealloc {
    //_umFeedback.delegate = nil;
}
@end
