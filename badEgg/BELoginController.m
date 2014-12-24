//
//  BELoginController.m
//  badEgg
//
//  Created by lilin on 13-11-13.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BELoginController.h"
#import "BEVIPController.h"
@interface BELoginController ()
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation BELoginController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)reback
{
    //返回
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
//    UIImage *leftButtonImage = [UIImage imageNamed:@"back.png"];
//    UIImage *leftbuttonNormal = [leftButtonImage
//                                 stretchableImageWithLeftCapWidth:10 topCapHeight:20];
//    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [leftButton setFrame: CGRectMake(0, 0, 54, 32)];
//    [leftButton setBackgroundImage:leftbuttonNormal forState:UIControlStateNormal];
//    [leftButton addTarget:self action:@selector(reback) forControlEvents:UIControlEventTouchDown];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
}

- (IBAction)login:(UIButton *)sender {
    NSMutableArray* controllerArray =[NSMutableArray arrayWithArray:self.tabBarController.viewControllers];
    BEVIPController* vip = [[APPUtils AppStoryBoard] instantiateViewControllerWithIdentifier:@"BEVIPNav"];
    [controllerArray replaceObjectAtIndex:2 withObject:vip];
    [self.tabBarController setViewControllers:controllerArray animated:YES];
}

- (IBAction)registerBadEgg:(id)sender {
    [self performSegueWithIdentifier:@"register" sender:self];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableview.layer.cornerRadius=6;
    _tableview.layer.masksToBounds=YES;
    _tableview.backgroundColor=[UIColor whiteColor];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{ return 2;}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{ return 40;}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"帐号：";
            IDTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(60, 6, 200, 30)];
            IDTextFiled.placeholder = @"输入账号";
            IDTextFiled.delegate =self;
            IDTextFiled.autocorrectionType = UITextAutocorrectionTypeNo;
            IDTextFiled.tag = 101;
            IDTextFiled.keyboardType = UIKeyboardTypeURL;
            IDTextFiled.keyboardType = UIKeyboardTypeASCIICapable;
            IDTextFiled.autocapitalizationType = UITextAutocapitalizationTypeNone;
            IDTextFiled.returnKeyType = UIReturnKeyNext;
            IDTextFiled.font = [UIFont systemFontOfSize:14];
            [cell.contentView addSubview:IDTextFiled];
        }else{
            cell.textLabel.text = @"密码：";
            PSTexrField = [[UITextField alloc] initWithFrame:CGRectMake(60, 6, 200, 30)];
            PSTexrField.secureTextEntry = YES;
            PSTexrField.placeholder = @"输入密码";
            PSTexrField.secureTextEntry = YES;
            PSTexrField.keyboardType = UIKeyboardTypeASCIICapable;
            PSTexrField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            PSTexrField.delegate =self;
            PSTexrField.returnKeyType = UIReturnKeyDone;
            PSTexrField.font = [UIFont systemFontOfSize:14];
            [cell.contentView addSubview:PSTexrField];
        }
    }
    
    return  cell;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == IDTextFiled) {
        [PSTexrField becomeFirstResponder];
    }else{
        [PSTexrField resignFirstResponder];
    }
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [IDTextFiled resignFirstResponder];
    [PSTexrField resignFirstResponder];
}


@end
