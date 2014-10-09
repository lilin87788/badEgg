//
//  FileUtils.h
//  badEgg
//
//  Created by lilin on 14-1-18.
//  Copyright (c) 2014年 surekam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtils : NSObject
+ (NSString *)formattedFileSize:(unsigned long long)size;

+ (long long) folderSizeAtPath:(NSString*) folderPath;

+ (NSString*)documentPath;

+(id)valueFromPlistWithKey:(NSString*)keyString;

+(void)setvalueToPlistWithKey:(NSString*)keyString Value:(id)valueString;

@end
