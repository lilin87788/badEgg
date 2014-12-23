//
//  badEggTests.m
//  badEggTests
//
//  Created by lilin on 13-10-10.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BEHttpRequest.h"
@interface badEggTests : XCTestCase

@end

@implementation badEggTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    [[BEHttpRequest sharedClient] requestFMDataWithPageNo:0 responseBlock:^(BOOL isOK, id data, NSError *error) {
        
    }];
}

@end
