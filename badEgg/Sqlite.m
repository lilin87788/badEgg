//
//  Sqlite.m
//  NewZhongYan
//
//  Created by lilin on 13-10-15.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "Sqlite.h"
#import "sqlite3.h"

static sqlite3 *dataBase = nil;
@implementation Sqlite
#pragma  mark -- 数据库的基本函数
id getColValue(sqlite3_stmt *stmt,int iCol);
+ (NSString *)dataBasePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"badegg.db"];
}

+ (BOOL)createContactDbFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[self dataBasePath]]) {
        return YES;
    }
    if ([fileManager createFileAtPath:[self dataBasePath] contents:nil attributes:nil]){
        return YES;
    }
    return NO;
}

+ (BOOL)openDb
{
    if (sqlite3_open([[self dataBasePath] UTF8String], &dataBase) != SQLITE_OK){
        sqlite3_close(dataBase);
        return NO;
    }
    return YES;
}

+ (void)closeDb
{
    sqlite3_close(dataBase);
}

+(void)patchBaseTables
{
    //    ("ALTER TABLE DATA_VER ADD COLUMN OWUID VARCHAR(48)");
    //    ("ALTER TABLE DATA_INITS ADD COLUMN OWUID VARCHAR(48)");
    //    ("UPDATE DATA_VER SET OWUID = ''");
    //    ("UPDATE DATA_INITS SET OWUID = ''");
}


//item.proName = dict[@"proName"];
//item.fileName = dict[@"fileName"];
//item.proTags = dict[@"proTags"];
//item.proIntro = dict[@"proIntro"];
//item.proIntroDto = dict[@"proIntroDto"];
//item.proIntroToSubString = dict[@"proIntroToSubString"];
//
//item.audioPathHttp = dict[@"audioPathHttp"];
//item.audioPath = dict[@"audioPath"];
//item.virtualAddress = dict[@"virtualAddress"];
//item.virtualAddressOld = dict[@"virtualAddressOld"];
//
//item.createTime = dict[@"createTime"];
//item.updateTime = dict[@"updateTime"];
//item.publishTime = dict[@"publishTime"];
//item.playTime = dict[@"playTime"];
//
//item.proAlbumId = dict[@"proAlbumId"];
//item.proCreater = dict[@"proCreater"];
//item.listenNum = dict[@"listenNum"];
//item.proId = dict[@"proId"];
//status 0 没有下载
//status 1 正在下载
//status 2 完成下载
+(BOOL)createFMTables
{
    NSString* t_badegg_sql       = [NSString stringWithFormat:@"create table  if not exists %@\
                                  (\
                                  id                   INTEGER             PRIMARY KEY AUTOINCREMENT ,\
                                  proName         text,\
                                  fileName          text,\
                                  proTags                text,\
                                  proIntro                text,\
                                  proIntroDto                text,\
                                  proIntroToSubString                text,\
                                  audioPathHttp                text,\
                                  audioPath             text,\
                                  virtualAddress                text,\
                                  virtualAddressOld                text,\
                                  createTime                TIMESTAMP,\
                                  updateTime                TIMESTAMP,\
                                  publishTime                TIMESTAMP,\
                                  playTime                TIMESTAMP,\
                                  proAlbumId                text,\
                                  proCreater                text,\
                                  listenNum                text,\
                                  dowStatus                INTEGER  default 0,\
                                  proId                text UNIQUE);",@"T_BADEGGALBUMS"];
    
    char *error = NULL;
    [self openDb];
    if (sqlite3_exec(dataBase, [t_badegg_sql UTF8String], 0, 0, &error) != SQLITE_OK) {
        NSLog(@"create table %@ error:%s",@"T_BADEGGALBUMS",error);
        [self closeDb];
        return NO;
    }

    [self closeDb];
    return YES;
}

+(void)createFMDownloadManagerTable
{
    NSString* t_badegg_sql  = [NSString stringWithFormat:@"create table  if not exists %@\
                               (\
                               id                   INTEGER             PRIMARY KEY AUTOINCREMENT ,\
                               proId                text UNIQUE);",@"T_BADEGGDOWNLOAD"];
    
    char *error = NULL;
    [self openDb];
    if (sqlite3_exec(dataBase, [t_badegg_sql UTF8String], 0, 0, &error) != SQLITE_OK) {
        NSLog(@"create table %@ error:%s",@"T_BADEGGDOWNLOAD",error);
    }
    [self closeDb];
}


+(void)setDBVersion
{
    [self openDb];
    char *error = NULL;
    NSString* oid_index = @"CREATE INDEX INDEX_T_ORGANIZATIONAL_OID ON T_ORGANIZATIONAL(OID)";
    if (sqlite3_exec(dataBase, [oid_index UTF8String], 0, 0, &error) != SQLITE_OK) {
        NSLog(@"create indices %@ error:%s",@"T_ORGANIZATIONAL",error);
        [self closeDb];
    }
    [[HNFileManager defaultManager] setvalueToPlistWithKey:@"DBVERSION" Value:@"1"];
    [self closeDb];
}

+(BOOL)createAllTable
{
    [self createFMTables];
    [self createFMDownloadManagerTable];
    [[HNFileManager defaultManager] setvalueToPlistWithKey:@"DBVERSION" Value:@"1"];
    return YES;
}

@end
