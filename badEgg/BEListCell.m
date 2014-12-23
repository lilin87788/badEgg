//
//  BEListCell.m
//  badEgg
//
//  Created by lilin on 13-11-13.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BEListCell.h"
#import "AFURLSessionManager.h"
#import "UIProgressView+AFNetworking.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "BEURLRequest.h"
#import "BEVIPController.h"
#import <AFNetworking/UIProgressView+AFNetworking.h>
@implementation BEListCell
{

    BEAlbumItem* albumItem;
}

@synthesize useDarkBackground;

-(BOOL)useDarkBackground
{
    return useDarkBackground;
}

- (IBAction)downLoadFMAlbum:(UIButton *)sender {
    if (![albumItem.dowStatus intValue]) {
        NSString* msg = [NSString stringWithFormat:@"<%@>\n到下载列表中",albumItem.proName];
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"添加" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [av show];
    }
}

//UPDATE Person SET Address = 'Zhongshan 23', City = 'Nanjing' WHERE LastName = 'Wilson' AND ID = '1'
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    {
        [self.taskProgressView setHidden:NO];
        NSString* url = [NSString stringWithString:albumItem.virtualAddress];
        NSString* filename = [NSString stringWithString:albumItem.fileName];
        //NSString *fullPath = [[FileUtils documentPath] stringByAppendingPathComponent:filename];
        AFURLSessionManager* manager = [BEHttpRequest sharedClient];
        NSURL *URL = [NSURL URLWithString:[url stringByAppendingString:@"?dow=true"]];
        BEURLRequest *request = [BEURLRequest requestWithURL:URL];
        request.album = albumItem;
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
            return [documentsDirectoryPath URLByAppendingPathComponent:filename];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            if (error) {
                [_downloadBtn setEnabled:YES];
            }
        }];
        [downloadTask resume];
        albumItem.downloadTask = downloadTask;
        [self.taskProgressView setProgressWithDownloadProgressOfTask:downloadTask animated:YES];
        [_downloadBtn setEnabled:NO];
    }
    return;
        
    if (buttonIndex != alertView.cancelButtonIndex) {
        NSString* url = [NSString stringWithString:albumItem.virtualAddress];
        NSString* filename = [NSString stringWithString:albumItem.fileName];
        NSString *fullPath = [NSHomeDirectory() stringByAppendingPathComponent:filename];
        if (IS_IOS7) {
            AFURLSessionManager* manager = [BEAppDelegate sharedURLSessionManager];
            NSURL *URL = [NSURL URLWithString:[url stringByAppendingString:@"?dow=true"]];
            BEURLRequest *request = [BEURLRequest requestWithURL:URL];
            request.album = albumItem;
             NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
                return [documentsDirectoryPath URLByAppendingPathComponent:filename];
            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                if (error) {
                    [_downloadBtn setEnabled:YES];
                }
            }];
            [downloadTask resume];
            [_downloadBtn setEnabled:NO];
            NSMutableArray* contentList = [BEVIPController sharedVIPContentList];
            [contentList addObject:albumItem];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addDownloadTask" object:0 userInfo:0];
            //[[DBQueue sharedbQueue] updateDataTotableWithSQL:[NSString stringWithFormat:@"UPDATE T_BADEGGALBUMS SET dowStatus = %d  WHERE proId = '%@'",BEDownloading,albumItem.proId]];
            //[_taskProgressView setHidden:NO];
        }else{
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            AFHTTPRequestOperation* operation = [manager GET:[url stringByAppendingString:@"?dow=true"]
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                                                         NSError *error;
                                                         NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&error];
                                                         if (error) {
                                                             NSLog(@"ERR: %@", [error description]);
                                                         } else {
                                                             NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
                                                             long long fileSize = [fileSizeNumber longLongValue];
                                                             
                                                             [_titleLabel setText:[NSString stringWithFormat:@"%lld", fileSize]];
                                                         }
                                                         
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         NSLog(@"Error: %@", error);
                                                     }];
            
            [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:fullPath append:NO]];
            [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead){
                float progress = (float)((float)totalBytesRead/totalBytesExpectedToRead);
                NSLog(@"%f",progress);
            }];
            [_downloadBtn setEnabled:NO];
        }
    }
}

- (void)setUseDarkBackground:(BOOL)flag
{
    if (flag != useDarkBackground || !self.backgroundView)
    {
        useDarkBackground = flag;
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView.frame = self.bounds;
    }
}

-(void)setRadioItems:(BEAlbumItem*)radio
{
    albumItem = radio;
    [[self.contentView viewWithTag:103] setTag:self.tag];
    _titleLabel.text = albumItem.proName;
    _timeLabel.text = albumItem.updateTime;
    if (albumItem.downloadTask) {
        [self.taskProgressView setProgressWithDownloadProgressOfTask:albumItem.downloadTask animated:YES];
        [self.taskProgressView setHidden:NO];
    }
}

-(void)prepareForReuse
{
    [self.taskProgressView setProgressWithDownloadProgressOfTask:nil animated:NO];
    [self.taskProgressView setHidden:YES];
}
@end
