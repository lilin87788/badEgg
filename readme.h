//
//  readme.h
//  badEgg
//
//  Created by lilin on 13-12-6.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#ifndef badEgg_readme_h
#define badEgg_readme_h
/**
 * 更新日记 2014年10月09日
 * 注意即将维护的新版本 即将放弃对ios5.x的支持
 * 本次维护即将集成cocoapods 方便对第三方库的管理 
 * 感谢 HysteriaPlayer 代码的支持 感谢 魏泽 对UI设计的贡献（如果上架侵犯了版权的话马上下架）
 
 * [!] The use of implicit sources has been deprecated. To continue using all of the sources currently on your machine, add the following to the top of your Podfile:
 
    source 'https://github.com/CocoaPods/Specs.git'
 */

/**
 *  Album 专辑
 */

/**
 *  经测试 没有AVAudioSessionCategoryPlayback  不能实现后台播放
 *  测试外音 播放 之前一直没有解决的问题
 *
 */

/**
 *  至此，您有播放App已经相当完美了，还有最后一个问题，那就是当用户使用耳机时，问题又来了。系统默认当插入耳机时，正在播放的声音不中断，直接切换到耳机播放，而当拔出耳机时，播放停止。如果这种行为满足您的要求，那OK，否则您就需要进一步研究耳机检测和声音路由切换的问题。
 
 * 怎么设置拔出耳机时 声音不停止
 */

/**
 *  知识点总结
 */

/**
 *  1Provisioning profile is expiring: 0409inHouse
 */

/**
 *  This seems to be a problem with trying to play videos on the simulator. I've had this problem for months now, and just ran into it again today when I was trying to play video on my simulator.
 
 The solution, while not great, is to use an actual device instead of the simulator for testing video playing.
 */

/**
 *  集成友盟的注意事项还没有添加
 */

#endif
