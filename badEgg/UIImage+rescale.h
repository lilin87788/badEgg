//
//  UIImage+rescale.h
//  HNZYiPad
//
//  Created by lilin on 13-6-20.
//  Copyright (c) 2013年 袁树峰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (rescale)
- (UIImage *)rescaleImageToSize:(CGSize)size;

- (UIImage *)cropImageToRect:(CGRect)cropRect;

- (CGSize)calculateNewSizeForCroppingBox:(CGSize)croppingBox;

- (UIImage *)cropCenterAndScaleImageToSize:(CGSize)cropSize;

- (UIImage *)splitImageWithImage:(UIImage*)image Rect:(CGRect)rect;

- (UIImage *)drawTextToImage:(NSString*)str Rect:(CGRect)rect Font:(UIFont*)font;
@end
