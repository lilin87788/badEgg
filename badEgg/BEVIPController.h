//
//  BEVIPController.h
//  badEgg
//
//  Created by lilin on 13-11-13.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMyAlbumCell.h"
@interface BEVIPController : BETableViewController
{
    UINib *cellNib;
}

@property (nonatomic,weak)IBOutlet BEMyAlbumCell *albumCell;

+(NSMutableArray*)sharedVIPContentList;
@end
