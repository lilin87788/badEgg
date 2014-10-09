//
//  BEQueuePlayer.m
//  badEgg
//
//  Created by lilin on 13-12-11.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BEQueuePlayer.h"
#import <AudioToolbox/AudioSession.h>
#import <objc/runtime.h>
#define USE_BADEGG        1 // use a xib file defining the cell
#define USE_Hysteria      0	// use a single view to draw all the content

static const void *Hysteriatag = &Hysteriatag;
static BEQueuePlayer *sharedInstance = nil;

@interface BEQueuePlayer ()
{
    BOOL routeChangedWhilePlaying;  //是不是正在播放时路径被改变
    BOOL interruptedWhilePlaying;   //是不是正在播放时被中断
    
    NSUInteger CHECK_AvoidPreparingSameItem;//检查是不是有相同的item
    NSUInteger items_count;
    
    
    UIBackgroundTaskIdentifier bgTaskId;
    UIBackgroundTaskIdentifier removedId;
    
    dispatch_queue_t BEGQueue;
    
    SourceItemGetter _sourceItemGetter;
    BEAlbumItemGetter _albumItemGetter;
    PlayerReadyToPlay _playerReadyToPlay;
    PlayerRateChanged _playerRateChanged;
    CurrentItemChanged _currentItemChanged;
    ItemReadyToPlay _itemReadyToPlay;
    PlayerPreLoaded _playerPreLoaded;
    PlayerFailed _playerFailed;
    PlayerDidReachEnd _playerDidReachEnd;
}
/**
 *  本实例播放器
 */
@property (nonatomic, strong) AVQueuePlayer *audioPlayer;
@property (nonatomic) BOOL PAUSE_REASON_ForcePause;  //是否因为强制而暂停
@property (nonatomic) BOOL PAUSE_REASON_Buffering;   //是否因为缓冲而暂停
@property (nonatomic) BOOL NETWORK_ERROR_getNextItem;//是否因为网络错误 播放下一首
@property (nonatomic) BEQueuePlayerRepeatMode repeatMode;
@property (nonatomic) BEPlayerShuffleMode shuffleMode;
@property (nonatomic) BEQueuePlayerStatus bequeuePlayerStatus;
@property (nonatomic, strong) NSMutableSet *playedItems;  // 已经播放了的Item


- (void)longTimeBufferBackground;
- (void)longTimeBufferBackgroundCompleted;
- (void)setHysteriaOrder:(AVPlayerItem *)item Key:(NSNumber *)order;
@end

@implementation BEQueuePlayer
@synthesize audioPlayer, playerItems, PAUSE_REASON_ForcePause, PAUSE_REASON_Buffering, NETWORK_ERROR_getNextItem, isInEmptySound;
#pragma mark -
#pragma mark ===========  Initialization, Setup  =========
#pragma mark -
+ (BEQueuePlayer *)sharedInstance
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [self alloc];
    });
    return sharedInstance;
}

- (id)initWithHandlerPlayerReadyToPlay:(PlayerReadyToPlay)playerReadyToPlay PlayerRateChanged:(PlayerRateChanged)playerRateChanged CurrentItemChanged:(CurrentItemChanged)currentItemChanged ItemReadyToPlay:(ItemReadyToPlay)itemReadyToPlay PlayerPreLoaded:(PlayerPreLoaded)playerPreLoaded PlayerFailed:(PlayerFailed)playerFailed PlayerDidReachEnd:(PlayerDidReachEnd)playerDidReachEnd
{
    if ((sharedInstance = [super init])) {
        //其中，第一个参数是标识队列的，第二个参数是用来定义队列的参数（目前不支持，因此传入NULL）。
        BEGQueue = dispatch_queue_create("com.surekam.badegg", NULL);
        playerItems = [NSMutableArray array];
        
        _repeatMode = BERepeatMode_off;
        _shuffleMode = BEShuffleMode_off;
        _bequeuePlayerStatus = BEQueuePlayerStatusUnknown;
        
        _playerReadyToPlay = playerReadyToPlay;
        _playerRateChanged = playerRateChanged;
        _currentItemChanged = currentItemChanged;
        _itemReadyToPlay = itemReadyToPlay;
        _playerPreLoaded = playerPreLoaded;
        _playerFailed = playerFailed;
        _playerDidReachEnd = playerDidReachEnd;
        
        [self backgroundPlayable];
        [self playEmptySound];
        [self AVAudioSessionNotification];
    }
    return sharedInstance;
}

- (void)backgroundPlayable
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    if (audioSession.category != AVAudioSessionCategoryPlayback)
    {
        UIDevice *device = [UIDevice currentDevice];
        if ([device respondsToSelector:@selector(isMultitaskingSupported)]) {
            if (device.multitaskingSupported) {
                NSError *aError = nil;
                [audioSession setCategory:AVAudioSessionCategoryPlayback error:&aError];
                if (aError) {
                    NSLog(@"set category error:%@",[aError description]);
                }
                aError = nil;
                [audioSession setActive:YES error:&aError];
                if (aError) {
                    NSLog(@"set active error:%@",[aError description]);
                }
                //audioSession.delegate = self;
            }
        }
    }else {
        //模拟器不能后台播放
        NSLog(@"unable to register background playback");
    }
    [self longTimeBufferBackground];
}

- (void)playEmptySound
{
    //播放一个0.1秒的empty声音
    NSString *filepath = [[NSBundle mainBundle]pathForResource:@"point1sec" ofType:@"mp3"];
    if ([[NSFileManager defaultManager]fileExistsAtPath:filepath]) {
        isInEmptySound = YES;
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:filepath]];
        playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"http://y1.eoews.com/assets/ringtones/2012/6/29/36195/mx8an3zgp2k4s5aywkr7wkqtqj0dh1vxcvii287a.mp3"]];
        audioPlayer = [AVQueuePlayer queuePlayerWithItems:@[playerItem]];
    }
}

//告诉手机 该应用会开启一个或多个长期运行的任务  应该在任务完成后结束后台任务
//这段代码不太懂
-(void)longTimeBufferBackground
{
    bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:removedId];
        bgTaskId = UIBackgroundTaskInvalid;
    }];
    
    if ((bgTaskId != UIBackgroundTaskInvalid && removedId == 0)
        ? YES
        : (removedId != UIBackgroundTaskInvalid))
    {
        [[UIApplication sharedApplication] endBackgroundTask: removedId];
    }
    removedId = bgTaskId;
}

/**
 *  长时间的后台缓冲
 */
-(void)longTimeBufferBackgroundCompleted
{
    BLog();
    if (bgTaskId != UIBackgroundTaskInvalid && removedId != bgTaskId)
    {
        [[UIApplication sharedApplication] endBackgroundTask: bgTaskId];
        removedId = bgTaskId;
    }
}

- (void)setupWithGetterBlock:(SourceItemGetter)itemBlock ItemsCount:(NSUInteger)count
{
    _sourceItemGetter = itemBlock;
    items_count = count;
}

- (void)setupAlbumWithGetterBlock:(BEAlbumItemGetter) itemBlock ItemsCount:(NSUInteger) count
{
    _albumItemGetter = itemBlock;
    items_count = count;
}

- (void)setItemsCount:(NSUInteger)count
{
    items_count = count;
}


#pragma mark -
#pragma mark ===========  Runtime AssociatedObject  =========
#pragma mark -
// 关联是指把两个对象相互关联起来，使得其中的一个对象作为另外一个对象的一部分。
- (void)setHysteriaOrder:(AVPlayerItem *)item Key:(NSNumber *)order {
    BLog();
    objc_setAssociatedObject(item, Hysteriatag, order, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)getHysteriaOrder:(AVPlayerItem *)item {
    BLog();
    return objc_getAssociatedObject(item, Hysteriatag);
}


#pragma mark -
#pragma mark ===========  AVAudioSession Notifications  =========
#pragma mark -
- (void)AVAudioSessionNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(interruption:)
                                                 name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    
    [audioPlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    [audioPlayer addObserver:self forKeyPath:@"rate" options:0 context:nil];
    [audioPlayer addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
}

#pragma mark -
#pragma mark ===========  Interruption, Route changed  =========
#pragma mark -

- (void)interruption:(NSNotification*)notification
{
    NSUInteger interuptionType = [[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    if (interuptionType == AVAudioSessionInterruptionTypeBegan && !PAUSE_REASON_ForcePause) {
        interruptedWhilePlaying = YES;
        [self pausePlayerForcibly:YES];
        [self pause];
    } else if (interuptionType == AVAudioSessionInterruptionTypeEnded && interruptedWhilePlaying) {
        interruptedWhilePlaying = NO;
        [self pausePlayerForcibly:NO];
        [self play];
    }
}

- (void)routeChange:(NSNotification *)notification
{
    NSUInteger routeChangeType = [[notification.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    if (routeChangeType == AVAudioSessionRouteChangeReasonOldDeviceUnavailable && !PAUSE_REASON_ForcePause) {
        routeChangedWhilePlaying = YES;
        [self pausePlayerForcibly:YES];
    } else if (routeChangeType == AVAudioSessionRouteChangeReasonNewDeviceAvailable && routeChangedWhilePlaying) {
        routeChangedWhilePlaying = NO;
        [self pausePlayerForcibly:NO];
        [self play];
    }
    NSLog(@"bequeuePlayer routeChanged: %@", routeChangeType == AVAudioSessionRouteChangeReasonNewDeviceAvailable ? @"New Device Available" : @"Old Device Unavailable");
}

#pragma mark -
#pragma mark ===========  KVO  =========
#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if (object == audioPlayer && [keyPath isEqualToString:@"status"]) {
        if (audioPlayer.status == AVPlayerStatusReadyToPlay) {
            if (_playerReadyToPlay != nil) {
                _playerReadyToPlay();
            }
            if (![self isPlaying]) {
                [audioPlayer play];
            }
        } else if (audioPlayer.status == AVPlayerStatusFailed) {
            NSLog(@"%@",audioPlayer.error);
            if (_playerFailed != nil) {
                _playerFailed();
            }
        }
    }
    
    if(object == audioPlayer && [keyPath isEqualToString:@"rate"]){
        if (!isInEmptySound && _playerRateChanged){
            _playerRateChanged();
        }else if (isInEmptySound && [audioPlayer rate] == 0.f){
            NSLog(@"audioPlayer rate %f",audioPlayer.rate);
            isInEmptySound = NO;
        }
    }
    
    if(object == audioPlayer && [keyPath isEqualToString:@"currentItem"]){
        if (_currentItemChanged != nil) {
            NSLog(@"NSKeyValueChangeNewKey = %@",NSKeyValueChangeNewKey);
            AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
            if (newPlayerItem != (id)[NSNull null]){
                _currentItemChanged(newPlayerItem);
            }
        }
    }
    
    if (object == audioPlayer.currentItem && [keyPath isEqualToString:@"status"]) {
        if (audioPlayer.currentItem.status == AVPlayerItemStatusFailed) {
            NSLog(@"------player item failed:%@",audioPlayer.currentItem.error);
            [self playNext];
        }else if (audioPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            if (_itemReadyToPlay != nil) {
                _itemReadyToPlay();
            }
            if (![self isPlaying] && !PAUSE_REASON_ForcePause) {
                [audioPlayer play];
            }
        }
    }
    
    if(object == audioPlayer.currentItem && [keyPath isEqualToString:@"loadedTimeRanges"]){
        NSLog(@"loadedTimeRanges");
        if (audioPlayer.currentItem.hash != CHECK_AvoidPreparingSameItem) {
            [self prepareNextPlayerItem];
            CHECK_AvoidPreparingSameItem = audioPlayer.currentItem.hash;
        }
        
        NSArray *timeRanges = (NSArray *)[change objectForKey:NSKeyValueChangeNewKey];
        if (timeRanges && [timeRanges count]) {
            CMTimeRange timerange=[[timeRanges objectAtIndex:0]CMTimeRangeValue];
            
            if (_playerPreLoaded)
            {
                _playerPreLoaded(CMTimeAdd(timerange.start, timerange.duration));
            }
            
            if (audioPlayer.rate == 0 && !PAUSE_REASON_ForcePause) {
                PAUSE_REASON_Buffering = YES;
                [self longTimeBufferBackground];
                
                CMTime bufferdTime = CMTimeAdd(timerange.start, timerange.duration);
                CMTime milestone = CMTimeAdd(audioPlayer.currentTime, CMTimeMakeWithSeconds(5.0f, timerange.duration.timescale));
                
                if (CMTIME_COMPARE_INLINE(bufferdTime , >, milestone)
                    && (audioPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay)
                    && (!interruptedWhilePlaying)
                    && (!routeChangedWhilePlaying))
                {
                    if (![self isPlaying]) {
                        NSLog(@"resume from buffering..");
                        PAUSE_REASON_Buffering = NO;
                        [audioPlayer play];
                        [self longTimeBufferBackgroundCompleted];
                    }
                }
            }
        }
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    BLog();
    NSNumber *CHECK_Order = [self getHysteriaOrder:audioPlayer.currentItem];
    if (CHECK_Order) {
        if (_repeatMode == BERepeatMode_one) {
            NSInteger currentIndex = [CHECK_Order integerValue];
            [self fetchAndPlayPlayerItem:currentIndex];
        }else if (_shuffleMode == BEShuffleMode_on){
            if (items_count == 1) {
                [self fetchAndPlayPlayerItem:0];
            }else{
                NSUInteger index;
                do {
                    index = arc4random() % items_count;
                } while (index == [CHECK_Order integerValue]);
                [self fetchAndPlayPlayerItem:index];
            }
        }else{
            if (NETWORK_ERROR_getNextItem || audioPlayer.items.count == 1)
            {
                NSLog(@"if (NETWORK_ERROR_getNextItem || audioPlayer.items.count == 1)");
                NETWORK_ERROR_getNextItem = NO;
                NSInteger nowIndex = [CHECK_Order integerValue];
                if (nowIndex + 1 < items_count) {
                    [self fetchAndPlayPlayerItem:(nowIndex + 1)];
                }else{
                    if (_repeatMode == BERepeatMode_off) {
                        [self pausePlayerForcibly:YES];
                        if (_playerDidReachEnd != nil)
                            _playerDidReachEnd();
                    }
                    [self fetchAndPlayPlayerItem:0];
                }
            }
        }
    }
}

#pragma mark -
#pragma mark ===========  Player Methods  =========
#pragma mark -
- (void) fetchAndPlayPlayerItem: (NSUInteger )startAt
{
    BOOL findInPlayerItems = NO;
    
    [audioPlayer pause];
    [audioPlayer removeAllItems];
    
    // if in shuffle mode, record played songs.
    if (_playedItems){
        [self recordPlayedItems:startAt];
    }
    // if enabled memory cache, search from playeritems first.
    for (AVPlayerItem *item in playerItems) {
        NSInteger checkIndex = [[self getHysteriaOrder:item] integerValue];
        if (checkIndex == startAt) {
            findInPlayerItems = YES;
            [item seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
                [self insertPlayerItem:item];
            }];
            break;
        }
    }
    
    if (!findInPlayerItems) {
        dispatch_async(BEGQueue, ^{
            

            
            
#if USE_BADEGG
            BEAlbumItem *item;
            if (_albumItemGetter && items_count > 0) {
                item = _albumItemGetter(startAt);
            }else{
                NSLog(@"please using setupWithGetterBlock: to setup your datasource");
                return ;
            }
#elif USE_Hysteria
            AVPlayerItem *item;
            if (_sourceItemGetter && items_count > 0) {
                item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:_sourceItemGetter(startAt)]];
            }else{
                NSLog(@"please using setupWithGetterBlock: to setup your datasource");
                return ;
            }
#endif
            if (item == nil) {
                return ;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setHysteriaOrder:item Key:[NSNumber numberWithInteger:startAt]];
                [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
                [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
                [playerItems addObject:item];
                [self insertPlayerItem:item];
            });
        });
    }
}

- (void) prepareNextPlayerItem
{
    NSNumber *CHECK_Order = [self getHysteriaOrder:audioPlayer.currentItem];
    NSUInteger nowIndex = [CHECK_Order integerValue];
    BOOL findInPlayerItems = NO;
    
    if (CHECK_Order) {
        if (_shuffleMode == BEShuffleMode_on || _repeatMode == BERepeatMode_one) {
            return;
        }
        if (nowIndex + 1 < items_count) {
            for (AVPlayerItem *item in playerItems) {
                NSInteger checkIndex = [[self getHysteriaOrder:item] integerValue];
                if (checkIndex == nowIndex +1) {
                    [item seekToTime:kCMTimeZero];
                    findInPlayerItems = YES;
                    [self insertPlayerItem:item];
                }
            }
            if (!findInPlayerItems) {
                dispatch_async(BEGQueue, ^{
#if USE_BADEGG
                    BEAlbumItem *item;
                    if (_albumItemGetter) {
                        item =  _albumItemGetter(nowIndex + 1);
                    }else{
                        NSLog(@"please using setupWithGetterBlock: to setup your datasource");
                        return ;
                    }
#elif USE_Hysteria
                    AVPlayerItem *item;
                    if (_sourceItemGetter) {
                        item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:_sourceItemGetter(nowIndex + 1)]];
                    }else{
                        NSLog(@"please using setupWithGetterBlock: to setup your datasource");
                        return ;
                    }
#endif
                    if (item == nil) {
                        return ;
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setHysteriaOrder:item Key:[NSNumber numberWithInteger:nowIndex + 1]];
                        [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
                        [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
                        [playerItems addObject:item];
                        [self insertPlayerItem:item];
                    });
                });
            }
        }else if (items_count > 1){
            if (_repeatMode == BERepeatMode_on) {
                for (AVPlayerItem *item in playerItems) {
                    NSInteger checkIndex = [[self getHysteriaOrder:item] integerValue];
                    if (checkIndex == 0) {
                        findInPlayerItems = YES;
                        [self insertPlayerItem:item];
                    }
                }
                if (!findInPlayerItems) {
                    dispatch_async(BEGQueue, ^{
#if USE_BADEGG
                        BEAlbumItem *item;
                        if (_albumItemGetter) {
                            item = _albumItemGetter(0);
                        }else{
                            NSLog(@"please using setupWithGetterBlock: to setup your datasource");
                            return ;
                        }
   
#elif USE_Hysteria
                        AVPlayerItem *item;
                        if (_sourceItemGetter) {
                            item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:_sourceItemGetter(0)]];
                        }else{
                            NSLog(@"please using setupWithGetterBlock: to setup your datasource");
                            return ;
                        }
#endif
                        if (item == nil) {
                            return ;
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self setHysteriaOrder:item Key:[NSNumber numberWithInteger:0]];
                            [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
                            [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
                            [playerItems addObject:item];
                            [self insertPlayerItem:item];
                        });
                    });
                }
            }
        }
    }
}

- (void)seekToTime:(double)seconds
{
    [audioPlayer seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC)];
}

- (void)seekToTime:(double)seconds withCompletionBlock:(void (^)(BOOL))completionBlock
{
    [audioPlayer seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        if (completionBlock) {
            completionBlock(finished);
        }
    }];
}

- (AVPlayerItem *)getCurrentItem
{
    return [audioPlayer currentItem];
}

- (void)play
{
    [audioPlayer play];
}

- (void)pause
{
    [audioPlayer pause];
}

- (void)playNext
{
    if (_shuffleMode == BEShuffleMode_on) {
        if (items_count == 1) {
            [self fetchAndPlayPlayerItem:0];
        }else{
            NSUInteger index;
            do {
                index = arc4random() % items_count;
            } while ([_playedItems containsObject:[NSNumber numberWithInteger:index]]);
            [self fetchAndPlayPlayerItem:index];
        }
    }else{
        NSInteger nowIndex = [[self getHysteriaOrder:audioPlayer.currentItem] integerValue];
        if (nowIndex + 1 < items_count) {
            [self fetchAndPlayPlayerItem:(nowIndex + 1)];
        }else{
            if (_repeatMode == BERepeatMode_off) {
                [self pausePlayerForcibly:YES];
                if (_playerDidReachEnd != nil)
                    _playerDidReachEnd();
            }
            [self fetchAndPlayPlayerItem:0];
        }
    }
}

- (void)playPrevious
{
    NSInteger nowIndex = [[self getHysteriaOrder:audioPlayer.currentItem] integerValue];
    if (nowIndex == 0)
    {
        if (_repeatMode == BERepeatMode_on) {
            [self fetchAndPlayPlayerItem:items_count - 1];
        }else{
            [audioPlayer.currentItem seekToTime:kCMTimeZero];
        }
    }else{
        [self fetchAndPlayPlayerItem:(nowIndex - 1)];
    }
}

- (CMTime)playerItemDuration
{
    NSError *err = nil;
    if ([audioPlayer.currentItem.asset statusOfValueForKey:@"duration" error:&err] == AVKeyValueStatusLoaded) {
        AVPlayerItem *playerItem = [audioPlayer currentItem];
        NSArray *loadedRanges = playerItem.seekableTimeRanges;
        if (loadedRanges.count > 0)
        {
            CMTimeRange range = [[loadedRanges objectAtIndex:0] CMTimeRangeValue];
            //Float64 duration = CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration);
            return (range.duration);
        }else {
            return (kCMTimeInvalid);
        }
    }else{
        return (kCMTimeInvalid);
    }
}

- (void)setPlayerRepeatMode:(BEQueuePlayerRepeatMode)mode
{
    switch (mode) {
        case BERepeatMode_off:
            _repeatMode = BERepeatMode_off;
            break;
        case BERepeatMode_on:
            _repeatMode = BERepeatMode_on;
            break;
        case BERepeatMode_one:
            _repeatMode = BERepeatMode_one;
            break;
        default:
            break;
    }
}

- (BEQueuePlayerRepeatMode)getPlayerRepeatMode
{
    switch (_repeatMode) {
        case BERepeatMode_one:
            return BERepeatMode_one;
            break;
        case BERepeatMode_on:
            return BERepeatMode_on;
            break;
        case BERepeatMode_off:
            return BERepeatMode_off;
            break;
        default:
            return BERepeatMode_off;
            break;
    }
}

- (void)setPlayerShuffleMode:(BEPlayerShuffleMode)mode
{
    switch (mode) {
        case BEShuffleMode_off:
            _shuffleMode = BEShuffleMode_off;
            [_playedItems removeAllObjects];
            _playedItems = nil;
            break;
        case BEShuffleMode_on:
            _shuffleMode = BEShuffleMode_on;
            _playedItems = [NSMutableSet set];
            [self recordPlayedItems:[[self getHysteriaOrder:audioPlayer.currentItem] integerValue]];
            break;
        default:
            break;
    }
}

- (BEPlayerShuffleMode)getPlayerShuffleMode
{
    switch (_shuffleMode) {
        case BEShuffleMode_on:
            return BEShuffleMode_on;
            break;
        case BEShuffleMode_off:
            return BEShuffleMode_off;
            break;
        default:
            return BEShuffleMode_off;
            break;
    }
}

//被强制暂停的原因:
//1  interuptionType == AVAudioSessionInterruptionTypeBegan && !PAUSE_REASON_ForcePause
//2  routeChangeType == AVAudioSessionRouteChangeReasonOldDeviceUnavailable && !PAUSE_REASON_ForcePause
//3  全部播完了
- (void)pausePlayerForcibly:(BOOL)forcibly
{
    if (forcibly)
        PAUSE_REASON_ForcePause = YES;
    else
        PAUSE_REASON_ForcePause = NO;
}

#pragma mark -
#pragma mark ===========  Player info  =========
#pragma mark -

- (BOOL)isPlaying
{
    NSLog(@"%f",audioPlayer.rate);
    if (!isInEmptySound){
        NSLog(@"[audioPlayer rate] = %f",[audioPlayer rate]);
        return [audioPlayer rate] != 0.f;
    }
    else
        return NO;
}

- (BEQueuePlayerStatus)getBEQueuePlayerStatus
{
    if ([self isPlaying])
        return BEQueuePlayerStatusPlaying;
    else if (PAUSE_REASON_Buffering)
        return BEQueuePlayerStatusBuffering;
    else if (PAUSE_REASON_ForcePause)
        return BEQueuePlayerStatusForcePause;
    else
        return BEQueuePlayerStatusUnknown;
}

- (float)getPlayerRate
{
    return audioPlayer.rate;
}

- (NSDictionary *)getPlayerTime
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)) {
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:0.0], @"CurrentTime", [NSNumber numberWithDouble:0.0], @"DurationTime", nil];
    }
    
	double duration = CMTimeGetSeconds(playerDuration);
	if (isfinite(duration))
	{
		double time = CMTimeGetSeconds([audioPlayer currentTime]);
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:time], @"CurrentTime", [NSNumber numberWithDouble:duration], @"DurationTime", nil];
	}else{
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:0.0], @"CurrentTime", [NSNumber numberWithDouble:0.0], @"DurationTime", nil];
    }
}

#pragma mark -
#pragma mark ===========  item Methods  =========
#pragma mark -
- (void) recordPlayedItems:(NSUInteger)order
{
    [_playedItems addObject:[NSNumber numberWithInteger:order]];
    
    if ([_playedItems count] == items_count){
        _playedItems = [NSMutableSet set];
    }
}

- (void)insertPlayerItem:(AVPlayerItem *)item
{
    BLog();
    if ([audioPlayer.items count] > 1) {
        for (int i = 1 ; i < [audioPlayer.items count] ; i ++) {
            NSLog(@"%@",[audioPlayer.items objectAtIndex:i]);
            [audioPlayer removeItem:[audioPlayer.items objectAtIndex:i]];
        }
    }
    if ([audioPlayer canInsertItem:item afterItem:nil]) {
        [audioPlayer insertItem:item afterItem:nil];
    }
}

- (void)removeAllItems
{
    for (AVPlayerItem *obj in playerItems) {
        [obj seekToTime:kCMTimeZero];
        [obj removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
        [obj removeObserver:self forKeyPath:@"status" context:nil];
    }
    
    [playerItems removeAllObjects];
    [audioPlayer removeAllItems];
}

- (void)removeItemAtIndex:(NSUInteger)order
{
    for (AVPlayerItem *item in [NSArray arrayWithArray:playerItems]) {
        NSUInteger CHECK_order = [[self getHysteriaOrder:item] integerValue];
        if (CHECK_order == order) {
            [playerItems removeObject:item];
            if ([audioPlayer.items indexOfObject:item] != NSNotFound) {
                [audioPlayer removeItem:item];
            }
        }else if (CHECK_order > order){
            [self setHysteriaOrder:item Key:[NSNumber numberWithInteger:CHECK_order -1]];
        }
    }
    items_count --;
}

- (void)removeQueuesAtPlayer
{
    while (audioPlayer.items.count > 1) {
        [audioPlayer removeItem:[audioPlayer.items objectAtIndex:1]];
    }
}

- (void)moveItemFromIndex:(NSUInteger)from toIndex:(NSUInteger)to
{
    for (AVPlayerItem *item in playerItems) {
        NSUInteger CHECK_index = [[self getHysteriaOrder:item] integerValue];
        if (CHECK_index == from || CHECK_index == to) {
            NSNumber *replaceOrder = CHECK_index == from ? [NSNumber numberWithInteger:to] : [NSNumber numberWithInteger:from];
            [self setHysteriaOrder:item Key:replaceOrder];
        }
    }
}

#pragma mark -
#pragma mark ===========   Deprecation  =========
#pragma mark -

- (void)deprecatePlayer
{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [audioPlayer removeObserver:self forKeyPath:@"status" context:nil];
    [audioPlayer removeObserver:self forKeyPath:@"rate" context:nil];
    [audioPlayer removeObserver:self forKeyPath:@"currentItem" context:nil];
    
    [self removeAllItems];
    
    _albumItemGetter = nil;
    _sourceItemGetter = nil;
    _playerReadyToPlay = nil;
    _playerRateChanged = nil;
    _currentItemChanged = nil;
    _itemReadyToPlay = nil;
    _playerFailed = nil;
    _playerDidReachEnd = nil;
    _playedItems = nil;
    
    [audioPlayer pause];
    audioPlayer = nil;
}

#pragma mark -
#pragma mark ===========   Memory cached  =========
#pragma mark -

- (BOOL) isMemoryCached
{
    return (playerItems == nil);
}

- (void) enableMemoryCached:(BOOL)isMemoryCached
{
    if (playerItems == nil && isMemoryCached) {
        playerItems = [NSMutableArray array];
    }else if (playerItems != nil && !isMemoryCached){
        playerItems = nil;
    }
}

@end
