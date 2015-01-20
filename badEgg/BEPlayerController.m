//
//  BEPlayerController.m
//  badEgg
//
//  Created by lilin on 13-11-28.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BEPlayerController.h"
#import "AudioButton.h"
#import "BESlider.h"

@interface BEPlayerController ()
@property (weak, nonatomic) IBOutlet AudioButton *PlayButton;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *curTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

@property (weak, nonatomic) IBOutlet UITextView *protrolTextView;
@property (weak, nonatomic) IBOutlet UISlider *BEPlaySlider;
@property (weak, nonatomic) IBOutlet BESlider *playSlider;

@end

@implementation BEPlayerController
- (void)configNowPlayingInfoCenter:(BEAlbumItem*)currentItem
{
    if (NSClassFromString(@"MPNowPlayingInfoCenter"))
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setObject:currentItem.proName forKey:MPMediaItemPropertyTitle];
        [dict setObject:@"播客" forKey:MPMediaItemPropertyArtist];
        [dict setObject:@"坏蛋调频" forKey:MPMediaItemPropertyAlbumTitle];
        
        MPMediaItemArtwork * mArt = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"badegg.jpg"]];
        [dict setObject:mArt forKey:MPMediaItemPropertyArtwork];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    }
}

-(void)initData
{
    [_BEPlaySlider setThumbImage:Image(@"playspot") forState:UIControlStateNormal];
    [_BEPlaySlider setMinimumTrackImage:Image(@"nx") forState:UIControlStateNormal];
    [_BEPlaySlider setMaximumTrackImage:Image(@"wx") forState:UIControlStateNormal];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"BEPlayerController"];
    [[BEsteriaPlayer sharedInstance] addDelegate:self];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"BEPlayerController"];

    [[BEsteriaPlayer sharedInstance] removeDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    BEsteriaPlayer* player = [BEsteriaPlayer sharedInstance];
    [player registerHandlerReadyToPlay:^(HysteriaPlayerReadyToPlay identifier){
        if (identifier == HysteriaPlayerReadyToPlayCurrentItem) {
            NSLog(@"HysteriaPlayerReadyToPlayCurrentItem");
        }else{
            NSLog(@"HysteriaPlayerReadyToPlayPlayer");
        }
    }];
    
    
    NSInteger currentIndex = [player getCurrentItemOrder];
    if (currentIndex == NSNotFound) {
        _titleLabel.text = self.currentItems.proName;
        _protrolTextView.text = self.currentItems.proIntro;
        [player fetchAndPlayPlayerItem:_currentIndex];
    }else{
        BEAlbumItem* curentitem = self.playerItems[[player getCurrentItemOrder]]; //;
        _titleLabel.text = curentitem.proName;
        _protrolTextView.text = curentitem.proIntro;
        if (self.isClickPlaingBtn) {
            
        }else{
            [player fetchAndPlayPlayerItem:_currentIndex];
            [player play];
        }
    }
    
//    
//    [player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:nil usingBlock:^(CMTime time) {
//        float current = [[BEsteriaPlayer sharedInstance] getPlayingItemCurrentTime];
//        float total = [[BEsteriaPlayer sharedInstance] getPlayingItemDurationTime];
//        _totalTimeLabel.text = [NSDate convertTimeFromSeconds:total];
//        _curTimeLabel.text = [NSDate convertTimeFromSeconds:current];
//        _BEPlaySlider.value = current/total;
//    }];

//    [player registerHandlerCurrentItemPreLoaded:^(CMTime time){
//        NSLog(@"HysteriaPlayerReadyToPlayPlayer");
//    }];

    [player registerHandlerProgress:^(NSString* currenttime,NSString* duration,float progress){
        _totalTimeLabel.text = duration;
        _curTimeLabel.text = currenttime;
        _BEPlaySlider.value = progress;
    }];

//    [player registerHandlerCurrentItemPreLoaded:^(CMTime time){
////        BEAlbumItem* item = [player getCurrentItem];
////        NSLog(@"registerHandlerCurrentItemPreLoaded %@",item.proName);
//    }];
    
//    [player registerHandlerFailed:^(HysteriaPlayerFailed identifier, NSError *error){
//        NSLog(@"%@",error);
//    }];
    
//    [player registerHandlerPlayerRateChanged:^{
//        if ([player isPlaying]) {
//            [_PlayButton setImage:Image(@"pausefm") forState:UIControlStateNormal];
//        }else{
//            [_PlayButton setImage:Image(@"playfm") forState:UIControlStateNormal];
//        }
//    } CurrentItemChanged:^(BEAlbumItem* item){
//        NSLog(@"CurrentItemChanged %@",item.proName);
//        [self configNowPlayingInfoCenter:item];
//        _titleLabel.text = item.proName;
//        _protrolTextView.text = item.proIntro;
//    } PlayerDidReachEnd:^{
//        BEAlbumItem* item = [player getCurrentItem];
//        NSLog(@"PlayerDidReachEnd %@",item.proName);
//    }];
    
    if ([player isPlaying]) {
        [_PlayButton setImage:Image(@"pausefm") forState:UIControlStateNormal];
    }else{
        [_PlayButton setImage:Image(@"playfm") forState:UIControlStateNormal];
    }
    //[_PlayButton startSpin];
    
   //[_PlayButton setProgress:.75];
}

- (IBAction)sliderValueChanged:(UISlider*)slider
{
    BEsteriaPlayer* player = [BEsteriaPlayer sharedInstance];
    CGFloat durationtime = [player getPlayingItemDurationTime];
    CGFloat currenttime = durationtime * slider.value;
    [player seekToTime:currenttime withCompletionBlock:^(BOOL complete){
        
    }];
}

- (IBAction)rewind:(id)sender
{
    
    BEsteriaPlayer* player = [BEsteriaPlayer sharedInstance];
    CGFloat currenttime=[player getPlayingItemCurrentTime];
    currenttime -= 30;
    [player seekToTime:currenttime withCompletionBlock:^(BOOL complete){
    
    }];
}

- (IBAction)Fastforward:(id)sender
{
    BEsteriaPlayer* player = [BEsteriaPlayer sharedInstance];
    CGFloat durationtime = [player getPlayingItemDurationTime];
    CGFloat currenttime = [player getPlayingItemCurrentTime];
    CGFloat seektime = currenttime + 30;
    if (seektime > durationtime) {
        seektime =  durationtime - 5;
    }
    [player seekToTime:seektime withCompletionBlock:^(BOOL complete){
        
    }];
}

- (IBAction)playFMMusic:(id)sender {
    BEsteriaPlayer *bePlayer = [BEsteriaPlayer sharedInstance];
    if ([bePlayer isPlaying]) {
        [bePlayer pausePlayerForcibly:YES];
        [bePlayer pause];
    }else{
        [bePlayer pausePlayerForcibly:NO];
        if ([bePlayer getCurrentItem]) {
            [bePlayer play];
        }else{
            [bePlayer fetchAndPlayPlayerItem:_currentIndex];
        }
    }
}

#pragma -mark 播放器代理函数
- (void)hysteriaPlayerCurrentItemChanged:(AVPlayerItem *)item
{
//    NSLog(@"CurrentItemChanged %@",item.proName);
//    [self configNowPlayingInfoCenter:item];
//    _titleLabel.text = item.proName;
//    _protrolTextView.text = item.proIntro;
}

- (void)hysteriaPlayerCurrentItemPreloaded:(CMTime)time
{
    //NSLog(@"current item pre-loaded time: %f", CMTimeGetSeconds(time));
    //NSLog(@"当前项目已经预加载: %f", CMTimeGetSeconds(time));
}

- (void)hysteriaPlayerDidReachEnd
{
    //BEAlbumItem* item = [[HysteriaPlayer sharedInstance] getCurrentItem];
    //NSLog(@"PlayerDidReachEnd %@",item.proName);
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"所有节目播放完成"
                                                   message:nil
                                                  delegate:self
                                         cancelButtonTitle:@"确定"
                                         otherButtonTitles:nil, nil];
    [alert show];
}

- (void)hysteriaPlayerRateChanged:(BOOL)isPlaying
{
    if (isPlaying) {
        [_PlayButton setImage:Image(@"pausefm") forState:UIControlStateNormal];
    }else{
        [_PlayButton setImage:Image(@"playfm") forState:UIControlStateNormal];
    }
}
@end
