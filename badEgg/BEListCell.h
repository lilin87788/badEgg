//
//  BEListCell.h
//  badEgg
//
//  Created by lilin on 13-11-13.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEAlbumItem.h"

@interface BEListCell : UITableViewCell
@property BOOL useDarkBackground;
-(void)setRadioItems:(BEAlbumItem*)radio;
@end
