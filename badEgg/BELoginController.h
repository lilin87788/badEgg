//
//  BELoginController.h
//  badEgg
//
//  Created by lilin on 13-11-13.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BELoginController : UIViewController<UITextFieldDelegate>
{
    UITextField* IDTextFiled;
    UITextField* PSTexrField;
    UIActivityIndicatorView* activity;
}
@end
