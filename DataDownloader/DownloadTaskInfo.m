//
//  DownloadTaskInfo.m
//  DataDownloader
//
//  Created by Javier Laguna on 10/02/2016.
//  Copyright © 2016 Medigarage Studios LTD. All rights reserved.
//

#import "DownloadTaskInfo.h"

#import "DownloadSession.h"

@interface DownloadTaskInfo ()

/**
 Identifies the object.
 */
@property (nonatomic, strong) NSString *title;

@end

@implementation DownloadTaskInfo

#pragma mark - Init

- (instancetype)initWithFileTitle:(NSString *)title
                              URL:(NSURL *)url
                  completionBlock:(void (^)(DownloadTaskInfo *downloadTask, NSURL *location, NSError *error))completionHandler
{
    self = [super init];
    
    if (self)
    {
        _task = [[DownloadSession downloadSession] downloadTaskWithURL:url];
        _title = title;
        _url = url;
        _downloadProgress = 0.0;
        _isDownloading = NO;
        _downloadComplete = NO;
        _completionHandler = completionHandler;
        _taskIdentifier = [@(_task.taskIdentifier) stringValue];
    }
    
    return self;
}


#pragma mark - Pause

- (void)pause
{
    self.isDownloading = NO;
    [self.task suspend];
    
    [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData)
     {
         self.taskResumeData = [[NSData alloc] initWithData:resumeData];
     }];
}

@end
