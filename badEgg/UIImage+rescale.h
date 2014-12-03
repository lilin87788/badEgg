//
//  UIImage+rescale.h
//  HNZYiPad
//
//  Created by lilin on 13-6-20.
//  Copyright (c) 2013年 袁树峰. All rights reserved.
//

#import <UIKit/UIKit.h>
#define imageBytesPerMB 1048576.0f
#define imageBytesPerPixel 4.0f
#define imagePixelsPerMB ( imageBytesPerMB / imageBytesPerPixel ) // 262144 pixels, for 4 bytes per pixel.

@interface UIImage (rescale)

- (UIImage *)rescaleImageToSize:(CGSize)size;

- (UIImage *)cropImageToRect:(CGRect)cropRect;

- (CGSize)calculateNewSizeForCroppingBox:(CGSize)croppingBox;

- (UIImage *)cropCenterAndScaleImageToSize:(CGSize)cropSize;

- (UIImage *)splitImageWithImage:(UIImage*)image Rect:(CGRect)rect;

- (UIImage *)drawTextToImage:(NSString*)str Rect:(CGRect)rect Font:(UIFont*)font;

- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImageWithUncompressedSizeInMB:(CGFloat)destImageSize
                             interpolationQuality:(CGInterpolationQuality)quality;

// helper functions
- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality;

- (CGAffineTransform)transformForOrientation:(CGSize)newSize;
@end
