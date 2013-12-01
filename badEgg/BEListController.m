//
//  BEListController.m
//  badEgg
//
//  Created by lilin on 13-11-13.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BEListController.h"
#import "BEListCell.h"
#import "BEPlayerController.h"
#define DARK_BACKGROUND  [UIColor colorWithRed:151.0/255.0 green:152.0/255.0 blue:155.0/255.0 alpha:1.0]
#define LIGHT_BACKGROUND [UIColor colorWithRed:172.0/255.0 green:173.0/255.0 blue:175.0/255.0 alpha:1.0]

@interface BEListController ()
{
    NSArray* contentList;
    TFHpple *xpathParser;
    NSArray *elements;
}
@end

@implementation BEListController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void) handleData
{
    [self.refreshControl endRefreshing];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
    [self.tableView reloadData];
}

-(void)RefreshViewControlEventValueChanged
{
    if (self.refreshControl.refreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"刷新中"];
        [self performSelector:@selector(handleData) withObject:nil afterDelay:2];
    }
}

-(void)initNavBar
{
    self.navigationItem.backBarButtonItem.title = @"返回";
    UIImage* navbgImage;
    if (System_Version_Small_Than_(7)) {
        navbgImage = [UIImage imageNamed:@"navbar44"];
    }else{
        navbgImage = [UIImage imageNamed:@"navbar64"] ;
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    }
    [self.navigationController.navigationBar setBackgroundImage:navbgImage  forBarMetrics:UIBarMetricsDefault];
}

-(void)initData
{
    
    NSURL *URL = [NSURL URLWithString:@"http://www.itings.com/badfm/usercontent_2590p0"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", [responseObject class]);
        xpathParser = [[TFHpple alloc] initWithHTMLData:responseObject];
        contentList  = [xpathParser searchWithXPathQuery:@"//div[@class='Ra_FXlist']"];     NSLog(@"------------------------------------------------------------------------------------------------");
        for (TFHppleElement *element in contentList) {
            for (NSString* key in [[element attributes] allKeys]) {
                NSLog(@"%@ :%@",key,[[element attributes] objectForKey:key]);
            }
            NSLog(@"------------------------------------------------------------------------------------------------");
        }
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    [manager GET:@"http://www.itings.com/badfm/usercontent_2590p0" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//         [self.tableView reloadData];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
    //op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
//    NSString *htmlString=[NSString stringWithContentsOfURL:[NSURL URLWithString: @"http://www.itings.com/badfm/usercontent_2590p0"] encoding: NSUTF8StringEncoding error:nil];
//    NSLog(@"%@",htmlString);
//    NSData *htmlData=[htmlString dataUsingEncoding:NSUTF8StringEncoding];
//    xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
//    contentList  = [xpathParser searchWithXPathQuery:@"//div[@class='Ra_FXlist']"];     NSLog(@"------------------------------------------------------------------------------------------------");
//    for (TFHppleElement *element in contentList) {
//        for (NSString* key in [[element attributes] allKeys]) {
//            NSLog(@"%@ :%@",key,[[element attributes] objectForKey:key]);
//        }
//        NSLog(@"------------------------------------------------------------------------------------------------");
//    }
    
   
}

/**
 *  学习xpath
 */

//1


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNavBar];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self initData];
    });
    contentList = [NSMutableArray array];
    UIRefreshControl* refreshcontrol = [[UIRefreshControl alloc]init];
    refreshcontrol.tintColor = COLOR(17, 168, 171);
    refreshcontrol.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
    [refreshcontrol addTarget:self action:@selector(RefreshViewControlEventValueChanged)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshcontrol;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    if ([segue.identifier isEqualToString:@"player"])
	{
        TFHppleElement *element = contentList[[self.tableView indexPathForSelectedRow].row - 1];
        BEPlayerController *playerController = segue.destinationViewController;
        playerController.FMUrl = [element attributes][@"audiopath"];
	}
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return contentList.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *CellIdentifier = @"introduce";
        UITableViewCell *cell;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        }else {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        }
        return cell;
    }else{
        static NSString *CellIdentifier = @"Cell";
        BEListCell *cell;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        }else {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        }
        cell.useDarkBackground = (indexPath.row % 2 == 0);
        TFHppleElement *element = contentList[indexPath.row - 1];
        [cell setRadioItems:element.attributes];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row) {
        cell.backgroundColor = ((BEListCell *)cell).useDarkBackground ? DARK_BACKGROUND : LIGHT_BACKGROUND;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 120.;
    }
    return 75.;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
