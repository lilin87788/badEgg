//
//  HysteriaPlayer.m
//
//  Created by saiday on 13/1/8.
//
//

#import "HysteriaPlayer.h"
#import <AudioToolbox/AudioSession.h>
#import <objc/runtime.h>

#define USE_BADEGG        1 // use a xib file defining the cell
#define USE_Hysteria      0	// use a single view to draw all the content
#define HYSTERIAPLAYER_CURRENT_TIME @"CurrentTime"
#define HYSTERIAPLAYER_DURATION_TIME @"DurationTime"


static const void *Hysteriatag = &Hysteriatag;
static dispatch_once_t onceToken;

@interface HysteriaPlayer ()
{
    BOOL routeChangedWhilePlaying;
    BOOL interruptedWhilePlaying;
    
    NSUInteger CHECK_AvoidPreparingSameItem;
    
    
    UIBackgroundTaskIdentifier bgTaskId;
    UIBackgroundTaskIdentifier removedId;
    
    dispatch_queue_t HBGQueue;
    
    BEPlayProgresser _progresser;
    Failed _failed;
    ReadyToPlay _readyToPlay;
    SourceAsyncGetter _sourceAsyncGetter;
    SourceSyncGetter _sourceSyncGetter;
    BEAlbumItemGetter _albumItemGetter;
    PlayerRateChanged _playerRateChanged;
    CurrentItemChanged _currentItemChanged;
    CurrentItemPreLoaded _currentItemPreLoaded;
    PlayerDidReachEnd _playerDidReachEnd;
}

@property (nonatomic, strong, readwrite) NSMutableArray *playerItems;
@property (nonatomic, readwrite) BOOL isInEmptySound;


/*
 * Private
 */
@property (nonatomic, strong) NSMutableSet *delegates;
@property (nonatomic) BOOL tookAudioFocus;


@property (nonatomic, strong) AVQueuePlayer *audioPlayer;
@property (nonatomic) BOOL PAUSE_REASON_ForcePause;
@property (nonatomic) BOOL PAUSE_REASON_Buffering;
@property (nonatomic) BOOL isPreBuffered;
@property (nonatomic) PlayerRepeatMode repeatMode;
@property (nonatomic) PlayerShuffleMode shuffleMode;
@property (nonatomic) HysteriaPlayerStatus hysteriaPlayerStatus;

@property (nonatomic, strong) NSMutableSet *playedItems;

- (void)longTimeBufferBackground;
- (void)longTimeBufferBackgroundCompleted;
- (void)setHysteriaOrder:(AVPlayerItem *)item Key:(NSNumber *)order;

@end

@implementation HysteriaPlayer
@synthesize delegates,audioPlayer, playerItems, PAUSE_REASON_ForcePause, PAUSE_REASON_Buffering, isInEmptySound, isPreBuffered;


static HysteriaPlayer *sharedInstance = nil;

#pragma mark -
#pragma mark ===========  Initialization, Setup  =========
#pragma mark -

+ (HysteriaPlayer *)sharedInstance {
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

+ (void)showAlertWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Player errors"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}


- (id)init {
    self = [super init];
    if (self) {
        HBGQueue = dispatch_queue_create("com.hysteria.queue", NULL);
        playerItems = [NSMutableArray array];
        delegates = [NSMutableSet set];
        
        _repeatMode = RepeatMode_off;
        _shuffleMode = ShuffleMode_off;
        _hysteriaPlayerStatus = HysteriaPlayerStatusUnknown;
        
        _failed = nil;
        _readyToPlay = nil;
        _sourceAsyncGetter = nil;
        _sourceSyncGetter = nil;
        
        _playerRateChanged = nil;
        _playerDidReachEnd = nil;
        _currentItemChanged = nil;
        _currentItemPreLoaded = nil;
//        
//        [self backgroundPlayable];
//        [self playEmptySound];
//        [self AVAudioSessionNotification];
        
    }
    return self;
}

- (void)preAction
{
    self.tookAudioFocus = YES;
    [self backgroundPlayable];
    [self playEmptySound];
    [self AVAudioSessionNotification];
}

-(void)registerHandlerPlayerRateChanged:(PlayerRateChanged)playerRateChanged CurrentItemChanged:(CurrentItemChanged)currentItemChanged PlayerDidReachEnd:(PlayerDidReachEnd)playerDidReachEnd
{
    _playerRateChanged = playerRateChanged;
    _currentItemChanged = currentItem/Users/linli/Desktop/untitled folder/badEgg/openresource/HysteriaPlayer/HysteriaPlayer.hChanged;
    _playerDidReachEnd = playerDidReachEnd;
}

- (void)registerHandlerCurrentItemPreLoaded:(CurrentItemPreLoaded)currentItemPreLoaded
{
    _currentItemPreLoaded = currentItemPreLoaded;
}

- (void)registerHandlerReadyToPlay:(ReadyToPlay)readyToPlay
{
    _readyToPlay = readyToPlay;
}

-(void)registerHandlerFailed:(Failed)failed
{
    _failed = failed;
}

- (void)registerHandlerProgress:(BEPlayProgresser)progresser
{
    _progresser = progresser;
}

- (void)setupSourceGetter:(BEAlbumItemGetter)itemBlock ItemsCount:(NSUInteger)count
{
    if (_albumItemGetter != nil)
        _albumItemGetter = nil;
    
    _albumItemGetter = itemBlock;
    _items_count = count;
}

- (void)asyncSetupSourceGetter:(SourceAsyncGetter)asyncBlock ItemsCount:(NSUInteger)count
{
    if (_albumItemGetter != nil)
        _albumItemGetter = nil;
    
    _sourceAsyncGetter = asyncBlock;
    _items_count = count;
}

- (void)setItemsCount:(NSUInteger)count
{
    _items_count = count;
}

-(void)updateProgress
{
    if (!isInEmptySound) {
        if (_progresser) {
            NSDictionary* dict = [self getPlayerTime];
            int currenttime = [dict[@"CurrentTime"] intValue];
            int duration = [dict[@"DurationTime"] intValue];
            float progress = (float)currenttime/duration;
            _progresser([NSDate convertTimeFromSeconds:currenttime],[NSDate convertTimeFromSeconds:duration],progress);
        }
    }
}

- (void)playEmptySound
{
    //play .1 sec empty sound
    NSString *filepath = [[NSBundle mainBundle]pathForResource:@"point1sec" ofType:@"mp3"];
    if ([[NSFileManager defaultManager]fileExistsAtPath:filepath]) {
        isInEmptySound = YES;
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:filepath]];
       // playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"http://y1.eoews.com/assets/ringtones/2012/6/29/36195/mx8an3zgp2k4s5aywkr7wkqtqj0dh1vxcvii287a.mp3"]];
        audioPlayer = [AVQueuePlayer queuePlayerWithItems:@[playerItem]];
        __weak HysteriaPlayer* this = self;
//        [audioPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1)
//                                                  queue:nil
//                                             usingBlock:^(CMTime time)
//         {
//             [this updateProgress];
//         }];
    }
}

- (void)backgroundPlayable
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    if (audioSession.category != AVAudioSessionCategoryPlayback) {
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
        NSLog(@"unable to register background playback");
    }
    
    [self longTimeBufferBackground];
}

/*
 * Tells OS this application starts one or more long-running tasks, should end background task when completed.
 */
-(void)longTimeBufferBackground
{
    bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:removedId];
        bgTaskId = UIBackgroundTaskInvalid;
    }];
    
    if (bgTaskId != UIBackgroundTaskInvalid && removedId == 0 ? YES : (removedId != UIBackgroundTaskInvalid)) {
        [[UIApplication sharedApplication] endBackgroundTask: removedId];
    }
    removedId = bgTaskId;
}

-(void)longTimeBufferBackgroundCompleted
{
    if (bgTaskId != UIBackgroundTaskInvalid && removedId != bgTaskId) {
        [[UIApplication sharedApplication] endBackgroundTask: bgTaskId];
        removedId = bgTaskId;
    }
}

#pragma mark -
#pragma mark ===========  Runtime AssociatedObject  =========
#pragma mark -

- (void)setHysteriaOrder:(BEAlbumItem *)item Key:(NSNumber *)order {
    objc_setAssociatedObject(item, Hysteriatag, order, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)getHysteriaOrder:(BEAlbumItem *)item {
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
    [audioPlayer addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
    [audioPlayer addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
}

#pragma mark -
#pragma mark ===========  Player Methods  =========
#pragma mark -

- (void) fetchAndPlayPlayerItem: (NSUInteger )startAt
{
    if (!self.tookAudioFocus){
        [self preAction];
    }
    BOOL findInPlayerItems = NO;
    
    [self.playedItems addObject:@(startAt)];
    [audioPlayer pause];
    [audioPlayer removeAllItems];
    
    findInPlayerItems = [self findSourceInPlayerItems:startAt];

    // if in shuffle mode, record played songs.
//    if (_playedItems)
//        [self recordPlayedItems:startAt];
    
    
    if (!findInPlayerItems) {
        NSAssert((_albumItemGetter != nil) || (_albumItemGetter != nil), @"please using setupSourceGetter:ItemsCount: to setup your datasource");
        if (_albumItemGetter != nil){
            [self getAndInsertMediaSource:startAt];
        }else if (_sourceAsyncGetter != nil){
            _sourceAsyncGetter(startAt);
        }
    }else if (audioPlayer.currentItem.status == AVPlayerStatusReadyToPlay) {//新添加的
        [audioPlayer play];
    }
}

- (void)getAndInsertMediaSource:(NSUInteger)index
{
    dispatch_async(HBGQueue, ^{
        NSAssert(_items_count > 0, @"your items count is zero, please check setupWithGetterBlock: or setItemsCount:");
        [self setupBEPlayerItem:_albumItemGetter(index) Order:index];
    });
}

- (void)setupBEPlayerItem:(BEAlbumItem *)item Order:(NSUInteger)index
{
    if (!item)  return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setHysteriaOrder:item Key:[NSNumber numberWithInteger:index]];
        //主线版本 去掉
//        [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
//        [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [playerItems addObject:item];
        [self insertPlayerItem:item];
    });
}

- (void)setupPlayerItem:(NSString *)url Order:(NSUInteger)index
{
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:url]];
    if (!item)
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setHysteriaOrder:item Key:[NSNumber numberWithInteger:index]];
//        [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
//        [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [playerItems addObject:item];
        [self insertPlayerItem:item];
    });
}

- (BOOL)findSourceInPlayerItems:(NSUInteger)index
{
    for (BEAlbumItem *item in playerItems) {
        NSInteger checkIndex = [[self getHysteriaOrder:item] integerValue];
        if (checkIndex == index) {
            [item seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
                [self insertPlayerItem:item];
            }];
            return YES;
        }
    }
    return NO;
}

- (void) recordPlayedItems:(NSUInteger)order
{
    [_playedItems addObject:[NSNumber numberWithInteger:order]];
    
    if ([_playedItems count] == _items_count)
        _playedItems = [NSMutableSet set];
}

- (void) prepareNextPlayerItem
{
    // check before added, prevent add the same songItem
    NSNumber *CHECK_Order = [self getHysteriaOrder:(BEAlbumItem*)audioPlayer.currentItem];
    NSUInteger nowIndex = [CHECK_Order integerValue];
    BOOL findInPlayerItems = NO;
    
    if (CHECK_Order) {
        if (_shuffleMode == ShuffleMode_on || _repeatMode == RepeatMode_one) {
            return;
        }
        if (nowIndex + 1 < _items_count) {
            findInPlayerItems = [self findSourceInPlayerItems:nowIndex +1];
            
            if (!findInPlayerItems) {
                if (_albumItemGetter != nil)
                    [self getAndInsertMediaSource:nowIndex + 1];
                else if (_sourceAsyncGetter != nil)
                    _sourceAsyncGetter(nowIndex + 1);
            }
        }else if (_items_count > 1){
            if (_repeatMode == RepeatMode_on) {
                findInPlayerItems = [self findSourceInPlayerItems:0];
                if (!findInPlayerItems) {
                    if (_albumItemGetter != nil)
                        [self getAndInsertMediaSource:0];
                    else if (_sourceAsyncGetter != nil)
                        _sourceAsyncGetter(0);
                }
            }
        }
    }
}

- (void)insertPlayerItem:(AVPlayerItem *)item
{
    if ([audioPlayer.items count] > 1) {
        for (int i = 1 ; i < [audioPlayer.items count] ; i ++) {
            [audioPlayer removeItem:[audioPlayer.items objectAtIndex:i]];
        }
    }
    if ([audioPlayer canInsertItem:item afterItem:nil]) {
        [audioPlayer insertItem:item afterItem:nil];
    }
}

- (void)removeAllItems
{
    for (BEAlbumItem *obj in playerItems) {
        [obj seekToTime:kCMTimeZero];
        @try{
            [obj removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
            [obj removeObserver:self forKeyPath:@"status" context:nil];
        }@catch(id anException){
            //do nothing, obviously it wasn't attached because an exception was thrown
        }
    }
    
    [playerItems removeAllObjects];
    [audioPlayer removeAllItems];
}

- (void)removeQueuesAtPlayer
{
    while (audioPlayer.items.count > 1) {
        [audioPlayer removeItem:[audioPlayer.items objectAtIndex:1]];
    }
}

- (void)removeItemAtIndex:(NSUInteger)order
{
    for (BEAlbumItem *item in [NSArray arrayWithArray:playerItems]) {
        NSUInteger CHECK_order = [[self getHysteriaOrder:item] integerValue];
        if (CHECK_order == order) {
            [playerItems removeObject:item];
            
            if ([audioPlayer.items indexOfObject:item] != NSNotFound) {
                [audioPlayer removeItem:item];
            }
        }else if (CHECK_order > order){
            [self setHysteriaOrder:item Key:@(CHECK_order -1)];
        }
    }
    
    _items_count --;
}

- (void)moveItemFromIndex:(NSUInteger)from toIndex:(NSUInteger)to
{
    for (BEAlbumItem *item in playerItems) {
        NSUInteger CHECK_index = [[self getHysteriaOrder:item] integerValue];
        if (CHECK_index == from || CHECK_index == to) {
            [self setHysteriaOrder:item Key:( CHECK_index == from ) ? @(to) : @(from)];
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

- (BEAlbumItem *)getCurrentItem
{
    return (BEAlbumItem*)[audioPlayer currentItem];
}

- (void)play
{
    [audioPlayer play];
}

- (void)pause
{
    [audioPlayer pause];
}

- (NSUInteger)randomIndex
{
    NSUInteger index;
    do {
        index = arc4random() % _items_count;
    } while ([_playedItems containsObject:[NSNumber numberWithInteger:index]]);
    
    return index;
}

- (void)playNext
{
    if (_shuffleMode == ShuffleMode_on) {
        [self fetchAndPlayPlayerItem:[self randomIndex]];
    } else {
        NSInteger nowIndex = [[self getHysteriaOrder:(BEAlbumItem*)audioPlayer.currentItem] integerValue];
        if (nowIndex + 1 < _items_count) {
            NSInteger nextIndex = [self randomIndex];
            if (nextIndex != NSNotFound) {
                [self fetchAndPlayPlayerItem:[self randomIndex]];
            } else {
                [self pausePlayerForcibly:YES];
                
                if (_playerDidReachEnd != nil){
                    _playerDidReachEnd();
                }
                
                for (id<HysteriaPlayerDelegate>delegate in delegates) {
                    if ([delegate respondsToSelector:@selector(hysteriaPlayerDidReachEnd)]) {
                        [delegate hysteriaPlayerDidReachEnd];
                    }
                }
            }
        }else{
            if (_repeatMode == RepeatMode_off) {
                [self pausePlayerForcibly:YES];
                if (_playerDidReachEnd != nil){
                    _playerDidReachEnd();
                }
                
                for (id<HysteriaPlayerDelegate> delegate in delegates) {
                    if ([delegate respondsToSelector:@selector(hysteriaPlayerDidReachEnd)]) {
                        [delegate hysteriaPlayerDidReachEnd];
                    }
                }
            }
            [self fetchAndPlayPlayerItem:0];
        }
    }
}

- (void)playPrevious
{
    NSInteger nowIndex = [[self getHysteriaOrder:(BEAlbumItem*)audioPlayer.currentItem] integerValue];
    if (nowIndex == 0)
    {
        if (_repeatMode == RepeatMode_on) {
            [self fetchAndPlayPlayerItem:_items_count - 1];
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
    //modified by lilin 解决状态为unkown时 获取不到总时间的问题
    AVKeyValueStatus avStatus = [audioPlayer.currentItem.asset statusOfValueForKey:@"duration" error:&err];
    if (avStatus == AVKeyValueStatusLoaded || avStatus == AVKeyValueStatusUnknown ) {
        BEAlbumItem *playerItem = (BEAlbumItem*)[audioPlayer currentItem];
        NSArray *loadedRanges = playerItem.seekableTimeRanges;
        if (loadedRanges.count > 0)
        {
            CMTimeRange range = [[loadedRanges objectAtIndex:0] CMTimeRangeValue];
            return (range.duration);
        }else {
            return (kCMTimeInvalid);
        }
    }else{
        return (kCMTimeInvalid);
    }
}

- (void)setPlayerRepeatMode:(PlayerRepeatMode)mode
{
   _repeatMode = mode;
}

- (PlayerRepeatMode)getPlayerRepeatMode
{
    return _repeatMode;
}

- (void)setPlayerShuffleMode:(PlayerShuffleMode)mode
{
    switch (mode) {
        case ShuffleMode_off:
            _shuffleMode = ShuffleMode_off;
            [_playedItems removeAllObjects];
            _playedItems = nil;
            break;
        case ShuffleMode_on:
            _shuffleMode = ShuffleMode_on;
            _playedItems = [NSMutableSet set];
            //[self recordPlayedItems:[[self getHysteriaOrder:(BEAlbumItem*)audioPlayer.currentItem] integerValue]];
            if (audioPlayer.currentItem) {
                [self.playedItems addObject:[self getHysteriaOrder:(BEAlbumItem*)audioPlayer.currentItem]];
            }
            break;
        default:
            break;
    }
}

- (PlayerShuffleMode)getPlayerShuffleMode
{
    return _shuffleMode;
}

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
    if (!isInEmptySound){
        return [audioPlayer rate] != 0.f;
    }else{
        return NO;
    }
}

- (HysteriaPlayerStatus)getHysteriaPlayerStatus
{
    if ([self isPlaying])
        return HysteriaPlayerStatusPlaying;
    else if (PAUSE_REASON_ForcePause)
        return HysteriaPlayerStatusForcePause;
    else if (PAUSE_REASON_Buffering)
        return HysteriaPlayerStatusBuffering;
    else
        return HysteriaPlayerStatusUnknown;
}

- (float)getPlayerRate
{
    return audioPlayer.rate;
}


- (NSDictionary *)getPlayerTime
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)) {
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:0.0], HYSTERIAPLAYER_CURRENT_TIME, [NSNumber numberWithDouble:0.0], HYSTERIAPLAYER_DURATION_TIME, nil];
    }else{
    
    }
    
	double duration = CMTimeGetSeconds(playerDuration);
	if (isfinite(duration)) {
        double time = CMTimeGetSeconds([audioPlayer currentTime]);
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:time], HYSTERIAPLAYER_CURRENT_TIME, [NSNumber numberWithDouble:duration], HYSTERIAPLAYER_DURATION_TIME, nil];

	}else{
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:0.0], HYSTERIAPLAYER_CURRENT_TIME, [NSNumber numberWithDouble:0.0], HYSTERIAPLAYER_DURATION_TIME, nil];
    }
}

- (float)getPlayingItemCurrentTime
{
    CMTime itemCurrentTime = [[audioPlayer currentItem] currentTime];
    float current = CMTimeGetSeconds(itemCurrentTime);
    if (CMTIME_IS_INVALID(itemCurrentTime) || !isfinite(current))
        return 0.0f;
    else
        return current;
}

- (float)getPlayingItemDurationTime
{
    CMTime itemDurationTime = [self playerItemDuration];
    float duration = CMTimeGetSeconds(itemDurationTime);
    if (CMTIME_IS_INVALID(itemDurationTime) || !isfinite(duration))
        return 0.0f;
    else
        return duration;
}

- (id)addPeriodicTimeObserverForInterval:(CMTime)interval
                                   queue:(dispatch_queue_t)queue
                              usingBlock:(void (^)(CMTime time))block;
{
    id mTimeObserver = [audioPlayer addPeriodicTimeObserverForInterval:interval queue:queue usingBlock:block];
    return mTimeObserver;
}

#pragma mark -
#pragma mark ===========  Interruption, Route changed  =========
#pragma mark -

- (void)interruption:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSUInteger interuptionType = [[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    
    if (interuptionType == AVAudioSessionInterruptionTypeBegan && !PAUSE_REASON_ForcePause) {
        interruptedWhilePlaying = YES;
        [self pausePlayerForcibly:YES];
        [self pause];
    } else if (interuptionType == AVAudioSessionInterruptionTypeEnded && interruptedWhilePlaying) {
        interruptedWhilePlaying = NO;
        [self pausePlayerForcibly:NO];
        [self play];
    }
    NSLog(@"HysteriaPlayer interruption: %@", interuptionType == AVAudioSessionInterruptionTypeBegan ? @"began" : @"end");
}

- (void)routeChange:(NSNotification *)notification
{
    NSDictionary *routeChangeDict = notification.userInfo;
    NSUInteger routeChangeType = [[routeChangeDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    if (routeChangeType == AVAudioSessionRouteChangeReasonOldDeviceUnavailable && !PAUSE_REASON_ForcePause) {
        routeChangedWhilePlaying = YES;
        [self pausePlayerForcibly:YES];
    } else if (routeChangeType == AVAudioSessionRouteChangeReasonNewDeviceAvailable && routeChangedWhilePlaying) {
        routeChangedWhilePlaying = NO;
        [self pausePlayerForcibly:NO];
        [self play];
    }
    NSLog(@"HysteriaPlayer routeChanged: %@", routeChangeType == AVAudioSessionRouteChangeReasonNewDeviceAvailable ? @"New Device Available" : @"Old Device Unavailable");
}

#pragma mark -
#pragma mark ===========  KVO  =========
#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if(object == audioPlayer && [keyPath isEqualToString:@"status"]) {
        if (audioPlayer.status == AVPlayerStatusReadyToPlay) {
            if (_readyToPlay != nil) {
                _readyToPlay(HysteriaPlayerReadyToPlayPlayer);
            }
            if (![self isPlaying]) {
                [audioPlayer play];
            }
        } else if (audioPlayer.status == AVPlayerStatusFailed) {
            if (self.showErrorMessages){
                [HysteriaPlayer showAlertWithError:audioPlayer.error];
            }
            if (_failed != nil) {
                _failed(HysteriaPlayerFailedPlayer, audioPlayer.error);
            }
        }
    }
    
    if(object == audioPlayer && [keyPath isEqualToString:@"rate"]){//如果播放速度发生改变
        if (!isInEmptySound && _playerRateChanged){
            if (_playerRateChanged) {
                _playerRateChanged();
            }
            for (id<HysteriaPlayerDelegate>delegate in delegates) {
                if ([delegate respondsToSelector:@selector(hysteriaPlayerRateChanged:)]) {
                    [delegate hysteriaPlayerRateChanged:[self isPlaying]];
                }
            }
        }else{
            if ([audioPlayer rate] != 0.f) {//这个地方还需要测试
                isInEmptySound = NO;
                if (_playerRateChanged) {
                    _playerRateChanged();
                }
                for (id<HysteriaPlayerDelegate>delegate in delegates) {
                    if ([delegate respondsToSelector:@selector(hysteriaPlayerRateChanged:)]) {
                        [delegate hysteriaPlayerRateChanged:[self isPlaying]];
                    }
                }
            }
        }
    }
    
    if(object == audioPlayer && [keyPath isEqualToString:@"currentItem"]){
//        id obj = [change objectForKey:NSKeyValueChangeNewKey];
//        if (obj != (id)[NSNull null] && [obj isKindOfClass:[BEAlbumItem class]]) {
//            BEAlbumItem* newPlayerItem = obj;
//            if (_currentItemChanged) {
//                _currentItemChanged(newPlayerItem);
//            }
//            for (id<HysteriaPlayerDelegate>delegate in delegates) {
//                if ([delegate respondsToSelector:@selector(hysteriaPlayerCurrentItemChanged:)]) {
//                    [delegate hysteriaPlayerCurrentItemChanged:newPlayerItem];
//                }
//            }
//        }
        BEAlbumItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        BEAlbumItem *lastPlayerItem = [change objectForKey:NSKeyValueChangeOldKey];
        if (lastPlayerItem != (id)[NSNull null]) {
            isInEmptySound = NO;
            @try {
                [lastPlayerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
                [lastPlayerItem removeObserver:self forKeyPath:@"status" context:nil];
            } @catch(id anException) {
                //do nothing, obviously it wasn't attached because an exception was thrown
            }
        }
        
        if (newPlayerItem != (id)[NSNull null] && [newPlayerItem isKindOfClass:[BEAlbumItem class]]) {
            [newPlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
            [newPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
            if (_currentItemChanged) {
                _currentItemChanged(newPlayerItem);
            }
            
            for (id<HysteriaPlayerDelegate>delegate in delegates) {
                if ([delegate respondsToSelector:@selector(hysteriaPlayerCurrentItemChanged:)]) {
                    [delegate hysteriaPlayerCurrentItemChanged:newPlayerItem];
                }
            }
        }
    }
    
    if (object == audioPlayer.currentItem && [keyPath isEqualToString:@"status"]) {
        isPreBuffered = NO;
        if (audioPlayer.currentItem.status == AVPlayerItemStatusFailed) {
            if (self.showErrorMessages){
                [HysteriaPlayer showAlertWithError:audioPlayer.currentItem.error];
            }
            if (_failed){
                _failed(HysteriaPlayerFailedCurrentItem, audioPlayer.currentItem.error);
            }
        }else if (audioPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            if (_readyToPlay != nil) {
                _readyToPlay(HysteriaPlayerReadyToPlayCurrentItem);
            }
            if (![self isPlaying] && !PAUSE_REASON_ForcePause) {
                [audioPlayer play];
            }
        }
    }
    
    if (audioPlayer.items.count > 1
        && object == [audioPlayer.items objectAtIndex:1]
        && [keyPath isEqualToString:@"loadedTimeRanges"]){
        isPreBuffered = YES;
    }
    
    if(object == audioPlayer.currentItem && [keyPath isEqualToString:@"loadedTimeRanges"]){
        if (audioPlayer.currentItem.hash != CHECK_AvoidPreparingSameItem) {
            [self prepareNextPlayerItem];
            CHECK_AvoidPreparingSameItem = audioPlayer.currentItem.hash;
        }
        
        NSArray *timeRanges = (NSArray *)[change objectForKey:NSKeyValueChangeNewKey];
        if (timeRanges && [timeRanges count]) {
            CMTimeRange timerange=[[timeRanges objectAtIndex:0]CMTimeRangeValue];
            
            if (_currentItemPreLoaded)
                _currentItemPreLoaded(CMTimeAdd(timerange.start, timerange.duration));
            
            for (id<HysteriaPlayerDelegate>delegate in delegates) {
                if ([delegate respondsToSelector:@selector(hysteriaPlayerCurrentItemPreloaded:)]) {
                    [delegate hysteriaPlayerCurrentItemPreloaded:CMTimeAdd(timerange.start, timerange.duration)];
                }
            }
            
            if (audioPlayer.rate == 0 && !PAUSE_REASON_ForcePause) {
                PAUSE_REASON_Buffering = YES;
                
                [self longTimeBufferBackground];
                
                CMTime bufferdTime = CMTimeAdd(timerange.start, timerange.duration);
                CMTime milestone = CMTimeAdd(audioPlayer.currentTime, CMTimeMakeWithSeconds(5.0f, timerange.duration.timescale));
                
                if (CMTIME_COMPARE_INLINE(bufferdTime , >, milestone) && audioPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay && !interruptedWhilePlaying && !routeChangedWhilePlaying) {
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
    NSNumber *CHECK_Order = [self getHysteriaOrder:(BEAlbumItem*)audioPlayer.currentItem];
    if (CHECK_Order) {
        if (_repeatMode == RepeatMode_one) {
            NSInteger currentIndex = [CHECK_Order integerValue];
            [self fetchAndPlayPlayerItem:currentIndex];
        } else if (_shuffleMode == ShuffleMode_on){
            NSInteger nextIndex = [self randomIndex];
            if (nextIndex != NSNotFound) {
                [self fetchAndPlayPlayerItem:[self randomIndex]];
            } else {
                [self pausePlayerForcibly:YES];
                for (id<HysteriaPlayerDelegate>delegate in delegates) {
                    if (_playerDidReachEnd != nil){
                        _playerDidReachEnd();
                    }
                    if ([delegate respondsToSelector:@selector(hysteriaPlayerDidReachEnd)]) {
                        [delegate hysteriaPlayerDidReachEnd];
                    }
                }
            }
        } else {
            if (audioPlayer.items.count == 1 || !isPreBuffered) {
                NSInteger nowIndex = [CHECK_Order integerValue];
                if (nowIndex + 1 < _items_count) {
                    [self playNext];
                }else{
                    if (_repeatMode == RepeatMode_off) {
                        [self pausePlayerForcibly:YES];
                        if (_playerDidReachEnd != nil)
                        {
                            _playerDidReachEnd();
                        }
                        for (id<HysteriaPlayerDelegate>delegate in delegates) {
                            if ([delegate respondsToSelector:@selector(hysteriaPlayerDidReachEnd)]) {
                                [delegate hysteriaPlayerDidReachEnd];
                            }
                        }
                    }
                    [self fetchAndPlayPlayerItem:0];
                }
            }
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
    [audioPlayer removeTimeObserver:self];
    
    [self removeAllItems];
    [delegates removeAllObjects];
    _failed = nil;
    _progresser = nil;
    _readyToPlay = nil;
    _sourceAsyncGetter = nil;
    _sourceSyncGetter = nil;
    _playerRateChanged = nil;
    _playerDidReachEnd = nil;
    _currentItemChanged = nil;
    _currentItemPreLoaded = nil;
    
    [audioPlayer pause];
    audioPlayer = nil;

    onceToken = 0;
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

#pragma mark -
#pragma mark ===========   Delegation  =========
#pragma mark -

- (void)addDelegate:(id<HysteriaPlayerDelegate>)delegate
{
    [delegates addObject:delegate];
}

- (void)removeDelegate:(id<HysteriaPlayerDelegate>)delegate
{
    [delegates removeObject:delegate];
}

@end