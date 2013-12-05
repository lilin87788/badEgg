//
//  UIColor+FlatUI.h
//  FlatUI
//
//  Created by Jack Flintermann on 5/3/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (FlatUI)

+ (UIColor *)DARK_BACKGROUND;
+ (UIColor *)LIGHT_BACKGROUND;
+ (UIColor *) colorFromHexCode:(NSString *)hexString;
+ (UIColor *) turquoiseColor;//绿松石
+ (UIColor *) greenSeaColor;//深绿
+ (UIColor *) emerlandColor;//浅绿
+ (UIColor *) nephritisColor;//浅绿 
+ (UIColor *) peterRiverColor;//天蓝
+ (UIColor *) belizeHoleColor;//比天蓝深点
+ (UIColor *) amethystColor;//紫晶
+ (UIColor *) wisteriaColor;//紫藤
+ (UIColor *) wetAsphaltColor;//湿沥青
+ (UIColor *) midnightBlueColor;//午夜蓝
+ (UIColor *) sunflowerColor;//葵花
+ (UIColor *) tangerineColor;//蜜桔
+ (UIColor *) carrotColor;//胡萝卜
+ (UIColor *) pumpkinColor;//南瓜
+ (UIColor *) alizarinColor;//茜素
+ (UIColor *) pomegranateColor;//石榴
+ (UIColor *) cloudsColor;//白云
+ (UIColor *) silverColor;//银
+ (UIColor *) concreteColor;
+ (UIColor *) asbestosColor;//石棉

+ (UIColor *) blendedColorWithForegroundColor:(UIColor *)foregroundColor
                              backgroundColor:(UIColor *)backgroundColor
                                 percentBlend:(CGFloat) percentBlend;

@end
