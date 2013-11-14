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
}
@end

@implementation BENewsController
-(void)initNavBar
{
    self.navigationItem.backBarButtonItem.title = @"返回";
    UIImage* navbgImage;
    if (System_Version_Small_Than_(7)) {
        navbgImage = [UIImage imageNamed:@"navibar441"];

    }else{
        navbgImage = [UIImage imageNamed:@"navibar641"] ;
    }
    [self.navigationController.navigationBar setBackgroundImage:navbgImage  forBarMetrics:UIBarMetricsDefault];
}

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
    NSUInteger numberPages = 3;
    
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < numberPages; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    viewControllers = controllers;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    [self initNavBar];
    [self initPageController];
    
    [_bgScrollView setContentSize:CGSizeMake(320* 3,_bgScrollView.frame.size.height)];
    [_bgScrollView setBackgroundColor:[UIColor colorWithPatternImage:Image(@"background")]];
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
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
        [viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
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
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // a possible optimization would be to unload the views+controllers which are no longer visible
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
