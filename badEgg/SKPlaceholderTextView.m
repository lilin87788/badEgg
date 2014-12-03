//
//  SKPlaceholderTextView.m
//  ZhongYan
//
//  Created by 李 林 on 12/29/12.
//  Copyright (c) 2012 surekam. All rights reserved.
//

#import "SKPlaceholderTextView.h"
@interface SKPlaceholderTextView ()
{
    UILabel  *placeholderLabel;
}

@property (nonatomic, retain) UILabel *placeHolderLabel;
-(void)textChanged:(NSNotification*)notification;
@end

@implementation SKPlaceholderTextView
@synthesize placeHolderLabel;
@synthesize placeholder;
@synthesize placeholderColor;


- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setPlaceholder:@""];
    [self setPlaceholderColor:[UIColor lightGrayColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark UITextView properties
- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (void)textChanged:(NSNotification *)notification
{
    //需要解释
    if([[self placeholder] length] == 0)
    {
        return;
    }
    
    if([[self text] length] == 0)
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    else
    {
        [[self viewWithTag:999] setAlpha:0];
    }
}

- (void)drawRect:(CGRect)rect
{
    if( [[self placeholder] length] > 0 )
    {
        if ( placeHolderLabel == nil )
        {
            placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8,8,self.bounds.size.width - 16,0)];
            placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            placeHolderLabel.numberOfLines = 0;
            placeHolderLabel.font = self.font;
            placeHolderLabel.backgroundColor = [UIColor clearColor];
            placeHolderLabel.textColor = self.placeholderColor;
            placeHolderLabel.alpha = 0;
            placeHolderLabel.tag = 999;
            [self addSubview:placeHolderLabel];
        }
        
        placeHolderLabel.text = [self.placeholder stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        [placeHolderLabel sizeToFit];
        [self sendSubviewToBack:placeHolderLabel];
    }
    
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 )
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    
    [super drawRect:rect];
}

//隐藏键盘，实现UITextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    if ([text isEqualToString:@"\n"]) {
        [self resignFirstResponder];
        return NO;
    }
    return YES;
}
@end
