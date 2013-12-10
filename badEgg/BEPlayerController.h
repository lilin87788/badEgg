//
//  BEPlayerController.h
//  badEgg
//
//  Created by lilin on 13-11-28.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "BEAlbumItem.h"
#import "BEPlayerItem.h"
@class AudioStreamer;
@interface BEPlayerController : UIViewController
{
    AudioStreamer *streamer;
    NSTimer *progressUpdateTimer;
}

@property(nonatomic,strong)NSString* FMUrl;
@property(nonatomic,strong)NSArray* albumItems;

+(AVQueuePlayer*)sharedAudio;
@end
