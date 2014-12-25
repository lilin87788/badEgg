//
//  BENewsDetailController.m
//  badEgg
//
//  Created by lilin on 13-11-13.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BENewsDetailController.h"
#import <QuartzCore/QuartzCore.h>

@interface BENewsDetailController ()
@property (weak, nonatomic) IBOutlet UIImageView *titleImage;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@end

@implementation BENewsDetailController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)updateView{
    NSString* sql = [NSString stringWithFormat:@"select * from T_BADEGGALBUMS order by publishTime desc limit %ld,1",(long)_pageindex];
    NSDictionary* album = [[DBQueue sharedbQueue] getSingleRowBySQL:sql];
    if (album) {
        _titleLabel.text = album[@"proName"];
        _subTitleLabel.text = album[@"proIntro"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"refreshCompleted" object:0 queue:0 usingBlock:^(NSNotification* note){
        [self updateView];
    }];
    [self updateView];
    _titleLabel.layer.cornerRadius = 6;
    _titleLabel.alpha = 0.3;
    _subTitleLabel.layer.cornerRadius = 6;
    _titleLabel.font = [UIFont systemFontOfSize:16];
    _titleLabel.numberOfLines = 0;
    _titleLabel.frame = CGRectMake(49, 81, 222, 30);
    [_titleLabel sizeToFit];

    NSDate *date = [NSDate date];
    _dayLabel.text = [NSString stringWithFormat:@"%ld",(long)[date day]];
    _monthLabel.text = [NSString stringWithFormat:@"%ld %ld",(long)[date month],(long)[date year]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
