//
//  BENewsController.m
//  badEgg
//
//  Created by lilin on 13-10-12.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BENewsController.h"
#import "BENewsDetailController.h"
@interface BENewsController ()
{
    UIPageControl* pageController;
    NSArray *contentList;
    NSMutableArray *viewControllers;
    NSString* maxPublishTime;
}
@end

@implementation BENewsController

-(void)initPageController
{

    pageController = [[UIPageControl alloc] initWithFrame:CGRectMake((320 - 150)/2., BottomY - 49 - 40, 150, 40)];
    [pageController setNumberOfPages:3];
    [pageController setHidesForSinglePage:YES];
    [pageController setPageIndicatorTintColor:[UIColor blackColor]];
    [pageController setCurrentPageIndicatorTintColor:[UIColor whiteColor]];
    [pageController setCurrentPage:0];
    [pageController addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:pageController];
}

/**
 *  构造界面
 */

-(void)initData
{
    [_bgScrollView setContentSize:CGSizeMake(SCREEN_WIDTH * 3,_bgScrollView.frame.size.height)];
    [_bgScrollView setBackgroundColor:[UIColor colorWithPatternImage:Image(@"background")]];
    maxPublishTime = [[DBQueue sharedbQueue] maxPublishTime];
    if ([maxPublishTime integerValue] == 0) {
        
    }
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < 3; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    viewControllers = controllers;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    
    [SVProgressHUD showWithStatus:@"加载中..."];
    [[BEHttpRequest sharedClient] requestFMDataWithPageNo:0 responseBlock:^(BOOL isOK, BEAlbum *album, NSError *error) {
        if(isOK){
            [SVProgressHUD dismiss];
            [self initPageController];
            [self loadScrollViewWithPage:0];
            [self loadScrollViewWithPage:1];
        }else{
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
    
    

    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"BENewsController"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"BENewsController"];
}

- (void)loadScrollViewWithPage:(NSUInteger)page
{
    if (page >= 3){
        return;
    }
    
    BENewsDetailController *controller = [viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[APPUtils AppStoryBoard] instantiateViewControllerWithIdentifier:@"BENewsDetail"];
        controller.pageindex = page;
        controller.rootController = self;
        [viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    //111
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = _bgScrollView.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        
        [self addChildViewController:controller];
        [_bgScrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = CGRectGetWidth(_bgScrollView.frame);
    NSUInteger page = floor((_bgScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageController.currentPage = page;
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
}

- (void)gotoPage:(BOOL)animated
{
    NSInteger page = pageController.currentPage;
    
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    CGRect bounds = _bgScrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = 0;
    [_bgScrollView scrollRectToVisible:bounds animated:animated];
}

- (IBAction)changePage:(id)sender
{
    [self gotoPage:YES];    // YES = animate
}

@end
