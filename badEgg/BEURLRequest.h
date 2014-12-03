//
//  BEURLRequest.h
//  badEgg
//
//  Created by lilin on 14-4-8.
//  Copyright (c) 2014年 surekam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BEAlbumItem.h"
@interface BEURLRequest : NSURLRequest
@property(nonatomic,strong)BEAlbumItem* album;
@end
