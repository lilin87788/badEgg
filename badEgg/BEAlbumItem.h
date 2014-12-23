//
//  BEAlbumItem.h
//  badEgg
//
//  Created by lilin on 13-12-6.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

typedef enum : NSUInteger {
    BEUNDownload,
    BEDownloading,
    BEDownloaded
} BEdownloadStatus;


#import <Foundation/Foundation.h>
/**
 *  存储一条fm数据
 */
@interface BEAlbumItem : AVPlayerItem
@property(nonatomic,strong)NSString* proName;
@property(nonatomic,strong)NSString* fileName;
@property(nonatomic,strong)NSString* proTags;
@property(nonatomic,strong)NSString* proIntro;
@property(nonatomic,strong)NSString* proIntroDto;
@property(nonatomic,strong)NSString* proIntroToSubString;

@property(nonatomic,strong)NSString* audioPathHttp;
@property(nonatomic,strong)NSString* audioPath;
@property(nonatomic,strong)NSString* virtualAddress;
@property(nonatomic,strong)NSString* virtualAddressOld;

@property(nonatomic,strong)NSString* createTime;
@property(nonatomic,strong)NSString* updateTime;
@property(nonatomic,strong)NSString* publishTime;
@property(nonatomic,strong)NSString* playTime;

@property(nonatomic,strong)NSString* proAlbumId;
@property(nonatomic,strong)NSString* proCreater;
@property(nonatomic,strong)NSString* listenNum;
@property(nonatomic,strong)NSString* proId;
@property(nonatomic,strong)NSString* dowStatus;
@property(nonatomic,strong)NSURLSessionDownloadTask* downloadTask;
@end
