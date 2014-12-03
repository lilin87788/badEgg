//
//  FileUtils.m
//  badEgg
//
//  Created by lilin on 14-1-18.
//  Copyright (c) 2014年 surekam. All rights reserved.
//

#import "FileUtils.h"
#include "sys/stat.h"
#include <dirent.h>

@implementation FileUtils
+ (NSString *)documentPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

#pragma mark - 关于Plist的操作
//从plist文件中读数据 eg keyString 为 AllUnitLUPT 则是取得所有部门上次刷新的时间
//keyString 为 gpsw 则是取得保护密码
+(id)valueFromPlistWithKey:(NSString*)keyString
{
    NSString *filename=[[self documentPath] stringByAppendingPathComponent:@"config.plist"];
    return [[NSMutableDictionary dictionaryWithContentsOfFile:filename] objectForKey:keyString];
}

//写入plist文件 eg keyString 为 AllUnitLUPT 则是写入所有部门上次刷新的时间
//如果keyString为gpsw 则是设置保护密码
+(void)setvalueToPlistWithKey:(NSString*)keyString Value:(id)valueString
{
    NSString *filePath=[[self documentPath] stringByAppendingPathComponent:@"config.plist"];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath])
    {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"1",@"2", nil];
        [dic writeToFile:filePath atomically:YES];
    }
    NSMutableDictionary* dict = [ [ NSMutableDictionary alloc ] initWithContentsOfFile:filePath];
    [ dict setObject:valueString forKey:keyString];
    [ dict writeToFile:filePath atomically:YES ];
}

+ (long long) folderSizeAtPath:(NSString*) folderPath{
    return [self _folderSizeAtPath:[folderPath cStringUsingEncoding:NSUTF8StringEncoding]];
}

+ (long long) _folderSizeAtPath: (const char*)folderPath{
    long long folderSize = 0;
    DIR* dir = opendir(folderPath);
    if (dir == NULL) return 0;
    struct dirent* child;
    while ((child = readdir(dir))!=NULL) {
        if (child->d_type == DT_DIR && (
                                        (child->d_name[0] == '.' && child->d_name[1] == 0) || // 忽略目录 .
                                        (child->d_name[0] == '.' && child->d_name[1] == '.' && child->d_name[2] == 0) // 忽略目录 ..
                                        )) continue;
        
        size_t folderPathLength = strlen(folderPath);
        char childPath[1024]; // 子文件的路径地址
        stpcpy(childPath, folderPath);
        if (folderPath[folderPathLength-1] != '/'){
            childPath[folderPathLength] = '/';
            folderPathLength++;
        }
        stpcpy(childPath+folderPathLength, child->d_name);
        childPath[folderPathLength + child->d_namlen] = 0;
        if (child->d_type == DT_DIR){ // directory
            folderSize += [self _folderSizeAtPath:childPath]; // 递归调用子目录
            // 把目录本身所占的空间也加上
            struct stat st;
            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
        }else if (child->d_type == DT_REG || child->d_type == DT_LNK){ // file or link
            struct stat st;
            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
        }
    }
    closedir(dir);//add by lilin for leak
    return folderSize;
}

+ (NSString *)formattedFileSize:(unsigned long long)size
{
    //取整 edit by ysf
	NSString *formattedStr = nil;
    if (size == 0)
		formattedStr = @"0 B";
	else
		if (size > 0 && size < 1024)
            //			formattedStr = [NSString stringWithFormat:@"%qu bytes", size];
            formattedStr = [NSString stringWithFormat:@"%.0llu B", size];
        else
            if (size >= 1024 && size < pow(1024, 2))
                //                formattedStr = [NSString stringWithFormat:@"%.1f KB", (size / 1024.)];
                formattedStr = [NSString stringWithFormat:@"%.0f KB", (size / 1024.)];
            else
                if (size >= pow(1024, 2) && size < pow(1024, 3))
                    //                    formattedStr = [NSString stringWithFormat:@"%.2f MB", (size / pow(1024, 2))];
                    formattedStr = [NSString stringWithFormat:@"%.00f MB", (size / pow(1024, 2))];
                else
                    if (size >= pow(1024, 3))
                        //                        formattedStr = [NSString stringWithFormat:@"%.3f GB", (size / pow(1024, 3))];
                        formattedStr = [NSString stringWithFormat:@"%.00f GB", (size / pow(1024, 3))];
	return formattedStr;
}
@end
