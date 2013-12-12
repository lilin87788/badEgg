//
//  BEQueuePlayer.h
//  badEgg
//
//  Created by lilin on 13-12-11.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
typedef enum
{
    BEQueuePlayerStatusPlaying = 0,
    BEQueuePlayerStatusForcePause,
    BEQueuePlayerStatusBuffering,
    BEQueuePlayerStatusUnknown
}
BEQueuePlayerStatus;

typedef enum
{
    BERepeatMode_on = 0,
    BERepeatMode_one,
    BERepeatMode_off
}
BEQueuePlayerRepeatMode;

typedef enum
{
    BEShuffleMode_on = 0,
    BEShuffleMode_off
}
BEPlayerShuffleMode;

@interface BEQueuePlayer : NSObject<AVAudioPlayerDelegate>


@property (nonatomic, strong, readonly) NSMutableArray *playerItems;
@property (nonatomic, readonly) BOOL isInEmptySound;

+ (BEQueuePlayer *)sharedInstance;







/**
 *   检测声音输入设备
 *
 *  @return
 */
+ (BOOL)hasMicphone;

/**
 *  单例
 *
 *  @return
 */
@end
