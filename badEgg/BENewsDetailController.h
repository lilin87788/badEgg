//
//  BENewsDetailController.h
//  badEgg
//
//  Created by lilin on 13-11-13.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BENewsController.h"
@interface BENewsDetailController : UIViewController
@property NSInteger pageindex;
@property (weak,nonatomic)BENewsController* rootController;
@end
