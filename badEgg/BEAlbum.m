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
            BEAlbumItem* item = [[BEAlbumItem alloc] initWithAlbumItem:dict];
            [self.albumItem addObject:item];
        }
    }
    return self;
}

-(void)addAlbumItem:(BEAlbum *)album
{

}

-(void)show
{
    NSLog(@"%@  %@",self.curPage,self.totalPage);
    NSLog(@"%@",self.albumItem[0]);
}
@end
