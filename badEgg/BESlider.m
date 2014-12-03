//
//  BESlider.m
//  badEgg
//
//  Created by lilin on 13-12-10.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BESlider.h"
#import <objc/message.h>

#define POINT_OFFSET    (2)
#pragma mark - UIImage (YDSlider)

@interface UIImage (BESlider)
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
@end

@implementation UIImage (YDSlider)
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    UIImage *img = nil;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   color.CGColor);
    CGContextFillRect(context, rect);
    
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}
@end

#pragma mark - YDSlider

@interface BESlider () {
    UISlider*       _slider;
    UIProgressView* _progressView;
    BOOL            _loaded;
    
    id              _target;
    SEL             _action;
    
}
@end

@implementation BESlider
- (BEPopover *)popover
{
    if (_popover == nil) {
        //Default size, can be changed after
        [self addTarget:self action:@selector(updatePopoverFrame) forControlEvents:UIControlEventValueChanged];
        _popover = [[BEPopover alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y - 32, 40, 32)];
        [self updatePopoverFrame];
        _popover.alpha = 0;
        [self.superview addSubview:_popover];
    }
    
    return _popover;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self updatePopoverFrame];
    [self showPopoverAnimated:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hidePopoverAnimated:YES];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hidePopoverAnimated:YES];
    [super touchesCancelled:touches withEvent:event];
}

- (void)updatePopoverFrame
{
    //Inspired in Collin Ruffenach's ELCSlider https://github.com/elc/ELCSlider/blob/master/ELCSlider/ELCSlider.m#L53
    
    CGFloat minimum =  0.;
	CGFloat maximum = 1.;
	CGFloat value = self.value;
	
	if (minimum < 0.0) {
        
		value = self.value - minimum;
		maximum = maximum - minimum;
		minimum = 0.0;
	}
	
	CGFloat x = self.frame.origin.x;
    CGFloat maxMin = (maximum + minimum) / 2.0;
    
    x += (((value - minimum) / (maximum - minimum)) * self.frame.size.width) - (self.popover.frame.size.width / 2.0);
	
	if (value > maxMin) {
		
		value = (value - maxMin) + (minimum * 1.0);
		value = value / maxMin;
		value = value * 11.0;
		
		x = x - value;
        
	} else {
		
		value = (maxMin - value) + (minimum * 1.0);
		value = value / maxMin;
		value = value * 11.0;
		
		x = x + value;
	}
    
    CGRect popoverRect = self.popover.frame;
    popoverRect.origin.x = x;
    popoverRect.origin.y = self.frame.origin.y - popoverRect.size.height - 1;
    
    self.popover.frame = popoverRect;
}

- (void)showPopoverAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.popover.alpha = 1.0;
        }];
    } else {
        self.popover.alpha = 1.0;
    }
}

- (void)hidePopoverAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.popover.alpha = 0;
        }];
    } else {
        self.popover.alpha = 0;
    }
}

- (void)loadSubView {
    if (_loaded) return;
    _loaded = YES;
    
    self.backgroundColor = [UIColor clearColor];
    
    _slider = [[UISlider alloc] initWithFrame:self.bounds];
    _slider.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:_slider];
    
    CGRect rect = _slider.bounds;
    
    rect.origin.x += POINT_OFFSET;
    rect.size.width -= POINT_OFFSET*2;
    _progressView = [[UIProgressView alloc] initWithFrame:rect];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _progressView.center = _slider.center;
    _progressView.userInteractionEnabled = NO;
    
    [_slider addSubview:_progressView];
    [_slider sendSubviewToBack:_progressView];
    
    _progressView.progressTintColor = [UIColor darkGrayColor];
    _progressView.trackTintColor = [UIColor lightGrayColor];
    _slider.maximumTrackTintColor = [UIColor clearColor];
}

- (void)awakeFromNib {
    [self loadSubView];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self loadSubView];
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    [self loadSubView];
    
    _target = target;
    _action = action;
    [_slider addTarget:self action:@selector(onSliderValueChanged:) forControlEvents:controlEvents];
}

- (void)onSliderValueChanged:(UISlider* )slider {
    objc_msgSend(_target, _action, self);
}

/* setting & getting */
- (CGFloat)value {
    return _slider.value;
}

- (void)setValue:(CGFloat)value {
    _slider.value = value;
    [self updatePopoverFrame];
}

- (CGFloat)middleValue {
    return _progressView.progress;
}

- (void)setMiddleValue:(CGFloat)middleValue {
    _progressView.progress = middleValue;
}

- (UIColor* )thumbTintColor {
    return _slider.thumbTintColor;
}

- (void)setThumbTintColor:(UIColor *)thumbTintColor {
    [_slider setThumbTintColor:thumbTintColor];
}

- (UIColor* )minimumTrackTintColor {
    return _slider.minimumTrackTintColor;
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
    [_slider setMinimumTrackTintColor:minimumTrackTintColor];
}

- (UIColor* )middleTrackTintColor {
    return _progressView.progressTintColor;
}

- (void)setMiddleTrackTintColor:(UIColor *)middleTrackTintColor {
    _progressView.progressTintColor = middleTrackTintColor;
}

- (UIColor* )maximumTrackTintColor {
    return _progressView.trackTintColor;
}

- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
    _progressView.trackTintColor = maximumTrackTintColor;
}

- (UIImage* )thumbImage {
    return _slider.currentThumbImage;
}

- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state {
    [_slider setThumbImage:image forState:state];
}

- (UIImage* )minimumTrackImage {
    return _slider.currentMinimumTrackImage;
}

- (void)setMinimumTrackImage:(UIImage *)minimumTrackImage {
    [_slider setMinimumTrackImage:minimumTrackImage forState:UIControlStateNormal];
}

- (UIImage* )middleTrackImage {
    return _progressView.progressImage;
}

- (void)setMiddleTrackImage:(UIImage *)middleTrackImage {
    _progressView.progressImage = middleTrackImage;
}

- (UIImage* )maximumTrackImage {
    return _progressView.trackImage;
}

- (void)setMaximumTrackImage:(UIImage *)maximumTrackImage {
    [_slider setMaximumTrackImage:[UIImage imageWithColor:[UIColor clearColor] size:maximumTrackImage.size] forState:UIControlStateNormal];
    _progressView.trackImage = maximumTrackImage;
}
@end
