//
//  BEQueuePlayer.h
//  badEgg
//
//  Created by lilin on 13-12-11.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

/**
 *  Ability to play the first PlayerItem when your application is resigned active but first PlayerItem is still buffering.
 *  point1sec.mp3 这个文件用于  当一个 处于（resign active）状态的程序准备播放第一个item（但是这个item却在缓冲数据）时
 */

/**
\  播放器状态改变的代码块
 switch ([hysteriaPlayer getHysteriaPlayerStatus]) {
 case HysteriaPlayerStatusUnknown:
 
 break;
 case HysteriaPlayerStatusForcePause:
 
 break;
 case HysteriaPlayerStatusBuffering:
 
 break;
 case HysteriaPlayerStatusPlaying:
 
 default:
 break;
 }
 */

#import <AVFoundation/AVFoundation.h>
#import "BEAlbumItem.h"
/**
 *  播放器当前的状态
 */
typedef enum
{
    BEQueuePlayerStatusPlaying = 0, //正在播放
    BEQueuePlayerStatusForcePause,  //播放器被迫停止当Player的PAUSE_REASON_ForcePause 属性 变成 YES。
    BEQueuePlayerStatusBuffering,   //播放器被挂起因为没有缓冲数据
    BEQueuePlayerStatusUnknown      //播放器的状态未知
}
BEQueuePlayerStatus;

/**
 *  循环模式
 */
typedef enum
{
    BERepeatMode_on = 0,
    BERepeatMode_one,
    BERepeatMode_off
}
BEQueuePlayerRepeatMode;

/**
 *  随机模式
 */
typedef enum
{
    BEShuffleMode_on = 0,
    BEShuffleMode_off
}
BEPlayerShuffleMode;

/**
 *  获取item的路径
 *
 *  @param NSUInteger 第几个item
 *
 *  @return 返回item 对应的url
 */
typedef NSString * (^ SourceItemGetter)(NSUInteger);


typedef BEAlbumItem * (^ BEAlbumItemGetter)(NSUInteger);

/**
 *  播放器即将播放
 *  It will be called when Player is ready to play the PlayerItem, so play it. If you have play/pause buttons, should update their status after you starting play. 
 * 播放器准备播放 这时如果有一个播放停止按钮 在开始播放后你应该更新他妈的状态了
 */
typedef void (^ PlayerReadyToPlay)();

/**
 *  播放rate发生改变
 *  It will be called when player's rate changed, probely 1.0 to 0.0 or 0.0 to 1.0. Anyways you should update your interface to notice the user what's happening. HysteriaPlayer have
 * 当播放器的rate发生改变 不管以何种方式你都应该更新你的界面来提示用户发生了什么事情  播放器有以下状态帮助你了解当前播放器的状态
 */
typedef void (^ PlayerRateChanged)();

/**
 *  当前播放的radio发生改变
 *   It will be called when player's currentItem changed. If you have UI elements related to Playing item, should update them when called
 *  播放器当前的radio发生改变 如果你有UI元素（如 标题 艺术家 专辑名）关系到正在播放的item 你这时应该更新他们
 *  @param  改变后的item
 */
typedef void (^ CurrentItemChanged)(AVPlayerItem *);

/**
 *  item 即将被播放
 *  It will be called when current PlayerItem is ready to play.
 */
typedef void (^ ItemReadyToPlay)();

/**
 *  播放器失败
 *   It will be called when player just failed.
 */
typedef void (^ PlayerFailed)();

/**
 *  内容即将全部播放完成
 *  It will be called when player stops, reaching the end of playing queue and repeat is disabled.
 */
typedef void (^ PlayerDidReachEnd)();

/**
 *  播放器预加载完成
 *   It will be called when receive new buffer data
 *  @param CMTime
 */
typedef void (^ PlayerPreLoaded)(CMTime);


@interface BEQueuePlayer : NSObject<AVAudioPlayerDelegate>
{
    
}
@property (nonatomic, strong, readonly) NSMutableArray *playerItems;
@property (nonatomic, readonly) BOOL isInEmptySound;


+ (BEQueuePlayer *)sharedInstance;


/**
 *  初始化播放器
 *
 *  @param playerReadyToPlay  详见上面
 *  @param playerRateChanged  详见上面
 *  @param currentItemChanged 详见上面
 *  @param itemReadyToPlay    详见上面
 *  @param playerPreLoaded    详见上面
 *  @param playerFailed       详见上面
 *  @param playerDidReachEnd  详见上面
 *
 *  @return 被初始化的播放器
 */
- (instancetype)initWithHandlerPlayerReadyToPlay:(PlayerReadyToPlay)playerReadyToPlay PlayerRateChanged:(PlayerRateChanged)playerRateChanged CurrentItemChanged:(CurrentItemChanged)currentItemChanged ItemReadyToPlay:(ItemReadyToPlay)itemReadyToPlay PlayerPreLoaded:(PlayerPreLoaded)playerPreLoaded PlayerFailed:(PlayerFailed)playerFailed PlayerDidReachEnd:(PlayerDidReachEnd)playerDidReachEnd;
#pragma mark - 设置播放数据源
/**
 *  设置GetterBlock
 *  在你播放任何东西之前 设置播放器的数据源
 *  @param itemBlock
 *  @param count      告诉播放器数据源的个数
 */
- (void)setupWithGetterBlock:(SourceItemGetter) itemBlock ItemsCount:(NSUInteger) count;


- (void)setupAlbumWithGetterBlock:(BEAlbumItemGetter) itemBlock ItemsCount:(NSUInteger) count;

/**
 *  当播放器的数据发生改变时 你必须通过这个函数来改变播放器数据源的个数
 *
 *  @param count
 */
- (void)setItemsCount:(NSUInteger)count;

/**
 *  设置播放器从哪一个开始播放
 *
 *  @param startAt
 */
- (void)fetchAndPlayPlayerItem: (NSUInteger )startAt;


/**
 *  删除所有播放队列中的item
 */
- (void)removeAllItems;


/**
 *  大概的意思是删掉除去第一个之外所有的item
 */
- (void)removeQueuesAtPlayer;


/**
 *  删除某一个item
 *
 *  @param index
 */
- (void)removeItemAtIndex:(NSUInteger)index;


/**
 *  移动某一个item到指定位置
 *
 *  @param from
 *  @param to
 */
- (void)moveItemFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;


#pragma mark - 设置播放器
/**
 *  设置播放器以何种方式pause
 *  如何停止我的回放
 *  @param forcibly
 */
- (void)pausePlayerForcibly:(BOOL)forcibly;


/**
 *  Disable played item caching
 *  如果disable memory cache 播放器每次都会运行SourceItemGetter 即使media播放完成过
 *  使用方式:
 *  HysteriaPlayer *hysteriaPlayer = [HysteriaPlayer sharedInstance];
 *  [hysteriaPlayer enableMemoryCached:NO];
 *  @param isMemoryCached
 */
- (void)enableMemoryCached:(BOOL) isMemoryCached;


/**
 *  是不是已经缓存完成
 *
 *  @return
 */
- (BOOL)isMemoryCached;

/**
 *  销毁播放器 当不在需要它
 */
- (void)deprecatePlayer;
#pragma mark - 获取播放器的相关属性
/**
 *  获取播放器的状态
 *
 *  @return
 */
- (BEQueuePlayerStatus)getBEQueuePlayerStatus;

/**
 *  设置播放器的循环模式
 *
 *  @param mode
 */
- (void)setPlayerRepeatMode:(BEQueuePlayerRepeatMode)mode;

/**
 *  获取播放器的循环模式
 *
 *  @return
 */
- (BEQueuePlayerRepeatMode)getPlayerRepeatMode;


/**
 *  获取播放器洗牌模式是不是打开
 *  shuffle ['ʃʌfl]  洗牌，
 *  @return
 */
- (BEPlayerShuffleMode)getPlayerShuffleMode;
/**
 *  设置播放器的洗牌模式
 *
 *  @param mode
 */
- (void)setPlayerShuffleMode:(BEPlayerShuffleMode)mode;


/*
 * Get item's index of my working items:
 * 只是某一个item在播放队列中的位置
 */
- (NSNumber *)getHysteriaOrder:(AVPlayerItem *)item;


/**
 *  获取播放器的时间信息 使用方法
 *  NSDictionary *dict = [hysteriaPlayer getPlayerTime];
 *  double durationTime = [[dict objectForKey:@"DurationTime"] doubleValue];
 *  double currentTime = [[dict objectForKey:@"CurrentTime"] doubleValue];
 */
- (NSDictionary *)getPlayerTime;

/**
 *  当前正在播放的item
 *
 *  @return 
 */
- (AVPlayerItem *)getCurrentItem;

/**
 *  获取播放器 的rate
 *
 *  @return
 */
- (float)getPlayerRate;

/**
 *  是不是正在播放
 *
 *  @return 
 */
- (BOOL)isPlaying;
#pragma mark - 播放控制
- (void)play;
- (void)pause;
- (void)playPrevious;
- (void)playNext;
- (void)seekToTime:(double) CMTime;
- (void)seekToTime:(double) CMTime withCompletionBlock:(void (^)(BOOL finished))completionBlock;
@end
