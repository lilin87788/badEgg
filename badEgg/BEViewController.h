//
//  BEViewController.h
//  badEgg
//
//  Created by lilin on 13-10-10.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMFeedback.h"
@interface BEViewController : UITabBarController<UITabBarControllerDelegate,UMFeedbackDataDelegate>
{
    UMFeedback *_umFeedback;
}
- (void)feedbackSend;
@end
