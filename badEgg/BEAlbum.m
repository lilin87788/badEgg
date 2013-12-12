//
//  BEAlbum.m
//  badEgg
//
//  Created by lilin on 13-12-6.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BEAlbum.h"

@implementation BEAlbum
-(id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        self.curPage = dictionary[@"pageNo"];
        self.totalPage = dictionary[@"totalPages"];
        self.albumItem = [NSMutableArray arrayWithCapacity:15];
        for (NSDictionary*dict in dictionary[@"prolist"]) {
            //BEAlbumItem* item = [[BEAlbumItem alloc] initWithURL:[NSURL URLWithString:dict[@"audioPathHttp"]]];
            BEAlbumItem* item = [[BEAlbumItem alloc] initWithURL:[NSURL URLWithString:@"http://y1.eoews.com/assets/ringtones/2012/6/29/36195/mx8an3zgp2k4s5aywkr7wkqtqj0dh1vxcvii287a.mp3"]];
            item.proName = dict[@"proName"];
            item.fileName = dict[@"fileName"];
            item.proTags = dict[@"proTags"];
            item.proIntro = dict[@"proIntro"];
            item.proIntroDto = dict[@"proIntroDto"];
            item.proIntroToSubString = dict[@"proIntroToSubString"];
            
            item.audioPathHttp = dict[@"audioPathHttp"];
            item.audioPath = dict[@"audioPath"];
            item.virtualAddress = dict[@"virtualAddress"];
            item.virtualAddressOld = dict[@"virtualAddressOld"];
            
            item.createTime = dict[@"createTime"];
            item.updateTime = dict[@"updateTime"];
            item.publishTime = dict[@"publishTime"];
            item.playTime = dict[@"playTime"];
            
            item.proAlbumId = dict[@"proAlbumId"];
            item.proCreater = dict[@"proCreater"];
            item.listenNum = dict[@"listenNum"];
            item.proId = dict[@"proId"];
            
            [self.albumItem addObject:item];
        }
    }
    return self;
}

-(void)show
{
    NSLog(@"%@  %@",self.curPage,self.totalPage);
    NSLog(@"%@",self.albumItem[0]);
}
@end
