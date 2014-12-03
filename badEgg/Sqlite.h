//
//  Sqlite.h
//  NewZhongYan
//
//  Created by lilin on 13-10-15.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sqlite : NSObject
/**
 *  创建数据库文件
 *
 *  @return  是否创建成功
 */
+ (BOOL)createContactDbFile;


/**
 *  获取数据库文件的路径
 *
 *  @return 数据库文件的路径
 */
+ (NSString *)dataBasePath;


/**
 *  建表
 *
 *  @return 是否创建成功
 */
+(BOOL)createAllTable;


/**
 *  设置本地数据库的版本
 */
+(void)setDBVersion;
@end
