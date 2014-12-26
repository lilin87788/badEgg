//
//  BEAlbumItem.m
//  badEgg
//
//  Created by lilin on 13-12-6.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BEAlbumItem.h"

@implementation BEAlbumItem
-(void)show
{
    
}

- (instancetype)initWithURL:(NSURL *)URL AlbumItemInfomation:(NSDictionary*)dict
{
    self = [super initWithURL:URL];
    if (self) {
        self.proName = dict[@"proName"];
        self.fileName = dict[@"fileName"];
        self.proTags = dict[@"proTags"];
        self.proIntro = dict[@"proIntro"];
        self.proIntroDto = dict[@"proIntroDto"];
        self.proIntroToSubString = dict[@"proIntroToSubString"];
        
        self.audioPathHttp = dict[@"audioPathHttp"];
        self.audioPath = dict[@"audioPath"];
        self.virtualAddress = dict[@"virtualAddress"];
        self.virtualAddressOld = dict[@"virtualAddressOld"];
        
        self.createTime = dict[@"createTime"];
        self.updateTime = dict[@"updateTime"];
        self.publishTime = dict[@"publishTime"];
        self.playTime = dict[@"playTime"];
        
        self.proAlbumId = dict[@"proAlbumId"];
        self.proCreater = dict[@"proCreater"];
        self.listenNum = dict[@"listenNum"];
        self.proId = dict[@"proId"];
        self.downloadTask = nil;
    }
    return self;
}

- (instancetype)initWithAlbumItem:(NSDictionary*)dict
{
    NSURL* url;
    BOOL downloaded = [dict[@"downloaded"] boolValue];

    
    url = downloaded
    ? [NSURL fileURLWithPath:[[HNFileManager defaultManager] albumPathWithProId:dict[@"proId"]]]
    : [NSURL URLWithString:dict[@"audioPathHttp"]];
//    url = [NSURL URLWithString:@"http://y1.eoews.com/assets/ringtones/2012/6/29/36195/mx8an3zgp2k4s5aywkr7wkqtqj0dh1vxcvii287a.mp3"];
//    url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tryg" ofType:@"mp3"]];
    self = [super initWithURL:url];
    if (self) {
        self.proName = dict[@"proName"];
        self.fileName = dict[@"fileName"];
        self.proTags = dict[@"proTags"];
        self.proIntro = dict[@"proIntro"];
        self.proIntroDto = dict[@"proIntroDto"];
        self.proIntroToSubString = dict[@"proIntroToSubString"];
        
        self.audioPathHttp = dict[@"audioPathHttp"];
        self.audioPath = dict[@"audioPath"];
        self.virtualAddress = dict[@"virtualAddress"];
        self.virtualAddressOld = dict[@"virtualAddressOld"];
        
        self.createTime = dict[@"createTime"];
        self.updateTime = dict[@"updateTime"];
        self.publishTime = dict[@"publishTime"];
        self.playTime = dict[@"playTime"];
        
        self.proAlbumId = dict[@"proAlbumId"];
        self.proCreater = dict[@"proCreater"];
        self.listenNum = dict[@"listenNum"];
        self.proId = dict[@"proId"];
        self.downloadTask = nil;
        self.downloaded = downloaded;
    }
    return self;
}
@end
