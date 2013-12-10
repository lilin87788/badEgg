//
//  BEAlbum.h
//  badEgg
//
//  Created by lilin on 13-12-6.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BEAlbumItem.h"
/**
 *  该对象存储一页的数据
 */
@interface BEAlbum : NSObject
@property(nonatomic,strong)NSString* curPage;
@property(nonatomic,strong)NSString* totalPage;
@property(nonatomic,strong)NSMutableArray*  albumItem;

-(id)initWithDictionary:(NSDictionary*)dictionary;
-(void)show;
@end
