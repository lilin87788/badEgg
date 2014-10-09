//
//  SKPlaceholderTextView.h
//  ZhongYan
//
//  Created by 李 林 on 12/29/12.
//  Copyright (c) 2012 surekam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKPlaceholderTextView : UITextView
{
    NSString *placeholder;
    UIColor  *placeholderColor;
}

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;
@end
