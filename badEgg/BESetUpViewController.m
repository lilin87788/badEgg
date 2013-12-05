//
//  BESetUpViewController.m
//  badEgg
//
//  Created by 邱俊俊 on 13-11-5.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BESetUpViewController.h"

@interface BESetUpViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation BESetUpViewController
//- (void)viewWillAppear:(BOOL)animated
//{
//    UIImage *leftButtonImage = [UIImage imageNamed:@"back.png"];
//    UIImage *leftbuttonNormal = [leftButtonImage
//                                 stretchableImageWithLeftCapWidth:10 topCapHeight:20];
//    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [leftButton setFrame: CGRectMake(0, 0, 54, 32)];
//    [leftButton setBackgroundImage:leftbuttonNormal forState:UIControlStateNormal];
//    [leftButton addTarget:self action:@selector(reback) forControlEvents:UIControlEventTouchDown];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
//}
- (void)reback
{
    //返回
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableview.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else{
        return 4;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"setCell%d%d",indexPath.section,indexPath.row]];
    return cell;
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 25;
    return 10.0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
