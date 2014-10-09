//
//  BEMyAlbumCell.m
//  badEgg
//
//  Created by lilin on 14-4-3.
//  Copyright (c) 2014年 surekam. All rights reserved.
//

#import "BEMyAlbumCell.h"
#import "BEURLRequest.h"
@implementation BEMyAlbumCell
{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *timeLabel;
    
    BEAlbumItem* albumItem;
}

@synthesize useDarkBackground;

- (void)awakeFromNib
{
    AFURLSessionManager* manager = [BEAppDelegate sharedURLSessionManager];
    [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        float progress = (float)((float)totalBytesWritten/totalBytesExpectedToWrite);
        BEURLRequest* request = (BEURLRequest*)downloadTask.originalRequest;
        if ([[request.album proId] isEqualToString:albumItem.proId]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_taskProgressView setHidden:NO];
                self.taskProgressView.progress = progress;
            });
        }
    }];
    
    [manager setDownloadTaskDidFinishDownloadingBlock:^ NSURL*(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location)
     {
         NSLog(@"location = %@",location);
         return location;
     }];
    
    [manager setDownloadTaskDidResumeBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t fileOffset, int64_t expectedTotalBytes){
        NSLog(@"fileOffset = %lld  expectedTotalBytes = %lld ",fileOffset,expectedTotalBytes);
    }];
    
    [manager setTaskDidCompleteBlock:^(NSURLSession *session, NSURLSessionTask *task, NSError *error){
        BEURLRequest* request = (BEURLRequest*)task.originalRequest;
        if ([[request.album proId] isEqualToString:albumItem.proId]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.taskProgressView setHidden:YES];
            });
        }
    }];
}

-(BOOL)useDarkBackground
{
    return useDarkBackground;
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
    titleLabel.text = albumItem.proName;
    timeLabel.text = albumItem.updateTime;
    [_taskProgressView setHidden:YES];
}
@end
