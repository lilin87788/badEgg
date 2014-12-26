//
//  DBQueue.m
//  NewZhongYan
//
//  Created by lilin on 13-10-15.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "DBQueue.h"
#import "BEAlbum.h"
#import "BEAlbumItem.h"
static DBQueue *gSharedInstance = nil;

@implementation DBQueue
@synthesize dbQueue;
-(id)init
{
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"badegg.db"]];
    }
    return self;
}

+(DBQueue*)sharedbQueue
{
    if (gSharedInstance == nil) {
        gSharedInstance = [[DBQueue alloc] init];
    }
    return gSharedInstance;
}


-(NSString*)maxPublishTime
{
    NSString* sql =  @"select max(publishTime) publishTime from T_BADEGGALBUMS;";
    NSString*result = [[DBQueue sharedbQueue] getSingleRowBySQL:sql][@"publishTime"];
    if ([result isEqual:[NSNull null]]) {
        return @"0";
    }else{
        return result;
    }
}

//proName         text,\
//fileName          text,\
//proTags                text,\
//proIntro                text,\
//proIntroDto                text,\
//proIntroToSubString                text,\
//audioPathHttp                text,\
//audioPath             text,\
//virtualAddress                text,\
//virtualAddressOld                text,\
//createTime                text,\
//updateTime                text,\
//publishTime                text,\
//playTime                TIMESTAMP,\
//proAlbumId                TIMESTAMP,\
//proCreater                text,\
//listenNum                text,\
//proId                text
-(void)insertDataToLocalDataBaseWithAlbum:(BEAlbum*)album completeBlock:(BEBaseCompleteBlock)block
{
    [self.dbQueue inDatabase:^(FMDatabase *db){
        for (BEAlbumItem* items in album.albumItem) {
            if ([items.proId intValue] == 60637 || [items.proId intValue] == 70862) {//临时添加的补丁
                    items.proIntro = [items.proIntro stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                    items.proIntroDto = [items.proIntroDto stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            }
            NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO T_BADEGGALBUMS (proName,fileName,proTags,proIntro,proIntroDto,proIntroToSubString,audioPathHttp,audioPath,virtualAddress,virtualAddressOld,createTime,updateTime,publishTime,playTime,proAlbumId,proCreater,listenNum,proId) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",items.proName,items.fileName,items.proTags,items.proIntro,items.proIntroDto,items.proIntroToSubString,items.audioPathHttp,items.audioPathHttp,items.virtualAddress,items.virtualAddressOld,items.createTime,items.updateTime,items.publishTime,items.playTime,items.proAlbumId,items.proCreater,items.listenNum,items.proId];
            [db executeUpdate:sql];
            if ([db hadError]){
                if (db.lastErrorCode == SQLITE_CONSTRAINT) {
                    continue;
                }else{
                    NSLog(@"数据库插入错误:%@ 错误码%d",[db lastErrorMessage],db.lastErrorCode);
                }
            }
        }
    }];
    if (block) {
        block();
    }
}

-(void)downloadCompleteWithAlbumItem:(BEAlbumItem*)albumItem{
    [self.dbQueue inDatabase:^(FMDatabase *db){
        NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO T_BADEGGDOWNLOAD (proId) VALUES ('%@')",albumItem.proId];
        [db executeUpdate:sql];
        if ([db hadError]){
            if (db.lastErrorCode == SQLITE_CONSTRAINT) {
            }else{
                NSLog(@"数据库插入错误:%@ 错误码%d",[db lastErrorMessage],db.lastErrorCode);
            }
        }
    }];
}

-(BOOL)updateDataTotableWithSQL:(NSString*)sql
{
    __block BOOL result = YES;
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         [db executeUpdate:sql];
         if ([db hadError]) {
             result = NO;
         }
     }];
    return result;
}

-(NSInteger)CountOfQueryWithSQL:(NSString*)sql
{
    __block NSInteger count = 0;
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         FMResultSet *rs = [db executeQuery:sql];
         if ([db hadError]) {
             NSLog(@"dberror = %@",[db lastErrorMessage]);
         }else{
             while ([rs next])
             {
                 count ++;
             }
         }
         [rs close];
     }];
    return count;
}

-(NSDictionary*)getSingleRowBySQL:(NSString*)sql
{
    __block NSDictionary* result =nil;
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         FMResultSet *rs = [db executeQuery:sql];
         if ([db hadError]) {
             NSLog(@"---%@",[db lastErrorMessage]);
         }else{
             if ([rs next]) {
                 result = [NSDictionary dictionaryWithDictionary:rs.resultDictionary];
             }
         }
         [rs close];
     }];
    return result;
}

-(NSArray*)recordFromTableBySQL:(NSString*)sql
{
    __block NSMutableArray* result = [[NSMutableArray alloc] init];
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         [db setShouldCacheStatements:YES];
         FMResultSet *rs = [db executeQuery:sql];
         if ([db hadError]) {
             NSLog(@"dberror = %@",[db lastErrorMessage]);
         }
         while ([rs next]) {
             [result addObject: rs.resultDictionary];
         }
         [rs close];
     }];
    return result;
}

-(FMResultSet*)RSFromTableBySQL:(NSString*)sql
{
    __block FMResultSet* result = nil;
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         [db setShouldCacheStatements:YES];
         if ([db hadError]) {
             NSLog(@"dberror = %@",[db lastErrorMessage]);
         }
         result = [db executeQuery:sql];
     }];
    return result;
}

//
//这里肯定只有一条记录
//
-(int)intValueFromSQL:(NSString*)sql
{
    __block int result = 0;
    [self.dbQueue inDatabase:^(FMDatabase *db){
        if ([db hadError]) {
            NSLog(@"dberror = %@",[db lastErrorMessage]);
        }
        FMResultSet *rs = [db executeQuery:sql];
        if ([rs next])
        {
            result = [rs intForColumnIndex:0];
        }
        [rs close];
    }];
    return result;
}

//
//这里可定只有一条记录 取得字符串
//
-(NSString*)stringFromSQL:(NSString*)sql
{
    __block NSString* result = nil;
    [self.dbQueue inDatabase:^(FMDatabase *db)   {
        if ([db hadError]) {
            NSLog(@"dberror = %@",[db lastErrorMessage]);
        }
        FMResultSet *rs = [db executeQuery:sql];
        if ([rs next]) {
            result = [rs stringForColumnIndex:0];
        }
        [rs close];
    }];
    return result;
}

-(NSDate*)dateFromSql:(NSString*)sql
{
    __block NSDate* result = nil;
    [self.dbQueue inDatabase:^(FMDatabase *db)
     {
         [db setShouldCacheStatements:YES];
         FMResultSet *rs = [db executeQuery:sql];
         if ([db hadError]) {
             NSLog(@"dberror = %@",[db lastErrorMessage]);
         }
         if ([rs next]) {
             result = [rs dateForColumnIndex:0];
         }
         [rs close];
     }];
    return result;
}
@end
