//
//  BESlider.h
//  badEgg
//
//  Created by lilin on 13-12-10.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEPopover.h"

@interface BESlider : UIControl
@property (nonatomic, assign) CGFloat value;        /* From 0 to 1 */
@property (nonatomic, assign) CGFloat middleValue;  /* From 0 to 1 */

@property (nonatomic, strong) UIColor* thumbTintColor;
@property (nonatomic, strong) UIColor* minimumTrackTintColor;
@property (nonatomic, strong) UIColor* middleTrackTintColor;
@property (nonatomic, strong) UIColor* maximumTrackTintColor;

@property (nonatomic, readonly) UIImage* thumbImage;
@property (nonatomic, strong) UIImage* minimumTrackImage;
@property (nonatomic, strong) UIImage* middleTrackImage;
@property (nonatomic, strong) UIImage* maximumTrackImage;

@property (nonatomic, strong) BEPopover *popover;

- (void)showPopoverAnimated:(BOOL)animated;
- (void)hidePopoverAnimated:(BOOL)animated;
- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state;
@end
