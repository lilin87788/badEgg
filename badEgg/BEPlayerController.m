//
//  BEPlayerController.m
//  badEgg
//
//  Created by lilin on 13-11-28.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BEPlayerController.h"
#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>
#import <MediaPlayer/MPVolumeView.h>
#import "AudioButton.h"
#import "BESlider.h"
static AudioStreamer *player = nil;
static AVQueuePlayer  *queueplayer = nil;
@interface BEPlayerController ()
@property (weak, nonatomic) IBOutlet AudioButton *audioPlayerButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *curTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *protroLabel;
@property (weak, nonatomic) IBOutlet UIButton *PlayButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UISlider *BEPlaySlider;
@property (weak, nonatomic) IBOutlet BESlider *playSlider;

@end

@implementation BEPlayerController
+(AVQueuePlayer*)sharedAudio
{
    if (queueplayer == nil) {
        queueplayer = [[AVQueuePlayer alloc] init];
    }
    return queueplayer;
}
/**
 *  下一首 或者 上一首
 *
 *  @param n 通知
 */
-(void)AVPlayerItemTimeJumped:(NSNotification*)n
{
    NSLog(@"AVPlayerItemTimeJumped");
    [self configNowPlayingInfoCenter];
}

/**
 * 音乐播放到末尾
 *
 *  @param n 通知
 */
-(void)AVPlayerItemDidPlayToEndTime:(NSNotification*)n
{
    NSLog(@"AVPlayerItemDidPlayToEndTime");
}

/**
 *  <#Description#>
 *
 *  @param n <#n description#>
 */
-(void)AVPlayerItemFailedToPlayToEndTime:(NSNotification*)n
{
    NSLog(@"AVPlayerItemFailedToPlayToEndTimeErrorKey");
}

- (void)configNowPlayingInfoCenter
{
    BEAlbumItem* currentItem = (BEAlbumItem*)[BEPlayerController sharedAudio].currentItem;
    if (NSClassFromString(@"MPNowPlayingInfoCenter"))
    {
        
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        
        [dict setObject:currentItem.proName forKey:MPMediaItemPropertyTitle];
        
        [dict setObject:@"博客" forKey:MPMediaItemPropertyArtist];
        
        [dict setObject:@"坏蛋调频" forKey:MPMediaItemPropertyAlbumTitle];
        
        MPMediaItemArtwork * mArt = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"badegg.jpg"]];
        [dict setObject:mArt forKey:MPMediaItemPropertyArtwork];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    }
}

- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                NSLog(@"UIEventSubtypeRemoteControlTogglePlayPause");
                if ([[BEPlayerController sharedAudio] rate] != 0){
                    [[BEPlayerController sharedAudio] pause];
                }else{
                    [[BEPlayerController sharedAudio] play];

                }
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                NSLog(@"UIEventSubtypeRemoteControlPreviousTrack");
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                NSLog(@"UIEventSubtypeRemoteControlNextTrack");
                [[BEPlayerController sharedAudio] advanceToNextItem];
                [[BEPlayerController sharedAudio] play];
                break;
            default:
                break;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVPlayerItemTimeJumped:) name:AVPlayerItemTimeJumpedNotification object:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVPlayerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVPlayerItemFailedToPlayToEndTime:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:0];
    
    [_BEPlaySlider setThumbImage:Image(@"player-progress") forState:UIControlStateNormal];
    
    for (BEAlbumItem* item in _albumItems) {
        //item.audioPathHttp = @"http://y1.eoews.com/assets/ringtones/2012/6/29/36195/mx8an3zgp2k4s5aywkr7wkqtqj0dh1vxcvii287a.mp3";
        [[BEPlayerController sharedAudio] insertItem:item afterItem:0];
    }
    
    [[BEPlayerController sharedAudio] play];

    [[BEPlayerController sharedAudio] addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1)
                                                                   queue:nil
                                                              usingBlock:^(CMTime time)
    {
        BEAlbumItem* currentItem = (BEAlbumItem*)[BEPlayerController sharedAudio].currentItem;
        _titleLabel.text = currentItem.proName;
        _protroLabel.text = currentItem.proIntro;
        NSArray* loadedRanges = currentItem.seekableTimeRanges;
        if (loadedRanges.count > 0)
        {
            CMTimeRange range = [[loadedRanges objectAtIndex:0] CMTimeRangeValue];
            int duration = (int)(CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration));
            _totalTimeLabel.text = [NSDate convertTimeFromSeconds:duration];
            CMTime currentTime = [BEPlayerController sharedAudio].currentItem.currentTime;
            _curTimeLabel.text = [NSDate convertTimeFromSeconds:(int)CMTimeGetSeconds(currentTime)];
            _progressView.progress = CMTimeGetSeconds(currentTime)/duration;
            _BEPlaySlider.value = CMTimeGetSeconds(currentTime)/duration;
        }
    }];
}

- (IBAction)sliderValueChanged:(UISlider*)slider
{
    BEAlbumItem* currentItem = (BEAlbumItem*)[BEPlayerController sharedAudio].currentItem;
    NSArray* loadedRanges = currentItem.seekableTimeRanges;
    if (loadedRanges.count > 0)
    {
        CMTimeRange range = [[loadedRanges objectAtIndex:0] CMTimeRangeValue];
        float duration = CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration);
        int value = (int)duration * slider.value;
        [[BEPlayerController sharedAudio] seekToTime:CMTimeMakeWithSeconds(value, NSEC_PER_SEC)];
        [[BEPlayerController sharedAudio] play];
    }
}



- (void)destroyStreamer
{
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:ASStatusChangedNotification
         object:streamer];
        
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
		[streamer stop];
		streamer = nil;
	}
}

- (void)updateProgress:(NSTimer *)updatedTimer
{
	if (streamer.bitRate != 0.0)
	{
		double progress = streamer.progress;
		double duration = streamer.duration;
		
		if (duration > 0)
		{
            _audioPlayerButton.progress = progress/duration;
            NSLog(@"%f %f",progress,duration);
            //			[progressSlider setEnabled:YES];
            //			[progressSlider setValue:100 * progress / duration];
		}
		else
		{
            //			[progressSlider setEnabled:NO];
		}
	}
	else
	{
		//positionLabel.text = @"Time Played:";
	}
}

- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if ([streamer isWaiting])
	{
        [self spinButton];
	}
	else if ([streamer isPlaying])
	{
		[_audioPlayerButton.layer removeAllAnimations];
	}
	else if ([streamer isIdle])
	{
		[self destroyStreamer];
        [_audioPlayerButton.layer removeAllAnimations];
	}
}

- (void)createStreamer
{
	if (streamer)
	{
		return;
	}
    
	[self destroyStreamer];
    
	NSString *escapedValue =
    (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                          nil,
                                                                          (CFStringRef)_FMUrl,
                                                                          NULL,
                                                                          NULL,
                                                                          kCFStringEncodingUTF8));
    
	NSURL *url = [NSURL URLWithString:escapedValue];
	streamer = [[AudioStreamer alloc] initWithURL:url];
	
	progressUpdateTimer =
    [NSTimer
     scheduledTimerWithTimeInterval:0.1
     target:self
     selector:@selector(updateProgress:)
     userInfo:nil
     repeats:YES];
	[[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playbackStateChanged:)
     name:ASStatusChangedNotification
     object:streamer];
}

- (void)spinButton
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	CGRect frame = [_audioPlayerButton frame];
	_audioPlayerButton.layer.anchorPoint = CGPointMake(0.5, 0.5);
	_audioPlayerButton.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
	[CATransaction commit];
    
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
	[CATransaction setValue:[NSNumber numberWithFloat:2.0] forKey:kCATransactionAnimationDuration];
    
	CABasicAnimation *animation;
	animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.fromValue = [NSNumber numberWithFloat:0.0];
	animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
	animation.delegate = self;
	[_audioPlayerButton.layer addAnimation:animation forKey:@"rotationAnimation"];
	[CATransaction commit];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished
{
	if (finished)
	{
		[self spinButton];
	}
}

- (IBAction)playFMMusic:(id)sender {
    [streamer start];
}
@end
