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

@property(nonatomic,weak) IBOutlet UILabel *titleLabel;
@property(nonatomic,weak)  IBOutlet UILabel *timeLabel;
@property(nonatomic,weak)  IBOutlet UILabel *sizeLabel;
@property(nonatomic,weak)  IBOutlet UIButton *downloadBtn;

//@property BOOL useDarkBackground;



@property(nonatomic,weak)UITableView* tableView;
@property (weak, nonatomic) IBOutlet UIProgressView *taskProgressView;
-(void)setRadioItems:(BEAlbumItem*)radio;
@end
