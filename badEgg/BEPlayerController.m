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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    
    HysteriaPlayer *hysteriaPlayer = [HysteriaPlayer sharedInstance];
    [hysteriaPlayer addDelegate:self];
    
    HysteriaPlayer* player = [HysteriaPlayer sharedInstance];
    BEAlbumItem* curentitem = [player getCurrentItem];
    if (curentitem) {
        _titleLabel.text = curentitem.proName;
        _protrolTextView.text = curentitem.proIntro;
        if (self.isClickPlaingBtn) {
            NSLog(@"触发正在播放");
        }else{
            [player fetchAndPlayPlayerItem:_currentIndex];
            [player play];
        }
    }else{
        _titleLabel.text = self.currentItems.proName;
        _protrolTextView.text = self.currentItems.proIntro;
        [player fetchAndPlayPlayerItem:_currentIndex];
    }
    
    [player registerHandlerCurrentItemPreLoaded:^(CMTime time){
        NSLog(@"HysteriaPlayerReadyToPlayPlayer");
    }];

    [player registerHandlerProgress:^(NSString* currenttime,NSString* duration,float progress){
        _totalTimeLabel.text = duration;
        _curTimeLabel.text = currenttime;
        _BEPlaySlider.value = progress;
    }];

    [player registerHandlerReadyToPlay:^(HysteriaPlayerReadyToPlay identifier){
        if (identifier == HysteriaPlayerReadyToPlayCurrentItem) {
            NSLog(@"HysteriaPlayerReadyToPlayCurrentItem");
        }else{
            NSLog(@"HysteriaPlayerReadyToPlayPlayer");
        }
    }];
    
    [player registerHandlerCurrentItemPreLoaded:^(CMTime time){
//        BEAlbumItem* item = [player getCurrentItem];
//        NSLog(@"registerHandlerCurrentItemPreLoaded %@",item.proName);
    }];
    
    [player registerHandlerFailed:^(HysteriaPlayerFailed identifier, NSError *error){
        NSLog(@"%@",error);
    }];
    
    [player registerHandlerPlayerRateChanged:^{
        if ([player isPlaying]) {
            [_PlayButton setImage:Image(@"pausefm") forState:UIControlStateNormal];
        }else{
            [_PlayButton setImage:Image(@"playfm") forState:UIControlStateNormal];
        }
    } CurrentItemChanged:^(BEAlbumItem* item){
        NSLog(@"CurrentItemChanged %@",item.proName);
        [self configNowPlayingInfoCenter:item];
        _titleLabel.text = item.proName;
        _protrolTextView.text = item.proIntro;
    } PlayerDidReachEnd:^{
        BEAlbumItem* item = [player getCurrentItem];
        NSLog(@"PlayerDidReachEnd %@",item.proName);
    }];
    
    if ([player isPlaying]) {
        [_PlayButton setImage:Image(@"pausefm") forState:UIControlStateNormal];
    }else{
        [_PlayButton setImage:Image(@"playfm") forState:UIControlStateNormal];
    }
    //[_PlayButton startSpin];
    
   //[_PlayButton setProgress:.75];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"BEPlayerController"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"BEPlayerController"];
}


- (IBAction)sliderValueChanged:(UISlider*)slider
{
    HysteriaPlayer* player = [HysteriaPlayer sharedInstance];
    NSDictionary* dict =[player getPlayerTime];
    CGFloat durationtime = [dict[@"DurationTime"] floatValue];
    CGFloat currenttime = durationtime * slider.value;
    [player seekToTime:currenttime withCompletionBlock:^(BOOL complete){
        
    }];
}

- (IBAction)rewind:(id)sender
{
    
    HysteriaPlayer* player = [HysteriaPlayer sharedInstance];
    NSDictionary* dict =[player getPlayerTime];
    CGFloat currenttime = [dict[@"CurrentTime"] floatValue];
    currenttime -= 30;
    [player seekToTime:currenttime withCompletionBlock:^(BOOL complete){
    
    }];
}

- (IBAction)Fastforward:(id)sender
{
    HysteriaPlayer* player = [HysteriaPlayer sharedInstance];
    NSDictionary* dict =[player getPlayerTime];
    CGFloat durationtime = [dict[@"DurationTime"] floatValue];
    CGFloat currenttime = [dict[@"CurrentTime"] floatValue];
    CGFloat seektime = currenttime + 30;
    if (seektime > durationtime) {
        seektime =  durationtime - 5;
    }
    [player seekToTime:seektime withCompletionBlock:^(BOOL complete){
        
    }];
}

- (IBAction)playFMMusic:(id)sender {
    HysteriaPlayer *bePlayer = [HysteriaPlayer sharedInstance];
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
    NSLog(@"当前播放项目发生改变");
}

- (void)hysteriaPlayerCurrentItemPreloaded:(CMTime)time
{
    NSLog(@"current item pre-loaded time: %f", CMTimeGetSeconds(time));
    NSLog(@"当前项目已经预加载: %f", CMTimeGetSeconds(time));
}

- (void)hysteriaPlayerDidReachEnd
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"所有节目播放完成"
                                                   message:nil
                                                  delegate:self
                                         cancelButtonTitle:@"确定"
                                         otherButtonTitles:nil, nil];
    [alert show];
}

- (void)hysteriaPlayerRateChanged:(BOOL)isPlaying
{
    NSLog(@"player rate changed");
}
@end
