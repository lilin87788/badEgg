//
//  BEMyAlbumCell.h
//  badEgg
//
//  Created by lilin on 14-4-3.
//  Copyright (c) 2014年 surekam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEAlbumItem.h"
@interface BEMyAlbumCell : UITableViewCell
@property BOOL useDarkBackground;
@property (nonatomic,weak)IBOutlet UIProgressView *taskProgressView;
-(void)setRadioItems:(BEAlbumItem*)radio;
@end
