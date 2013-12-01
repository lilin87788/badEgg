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
@interface BEPlayerController ()
@property (weak, nonatomic) IBOutlet AudioButton *audioPlayerButton;

@end

@implementation BEPlayerController

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


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createStreamer];
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    volumeView.center = CGPointMake(150,370);
    [volumeView sizeToFit];
    [self.view addSubview:volumeView];
}
@end
