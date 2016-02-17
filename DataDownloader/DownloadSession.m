//
//  DownloadSession.m
//  DataDownloader
//
//  Created by Javier Laguna on 10/02/2016.
//  Copyright © 2016 Medigarage Studios LTD. All rights reserved.
//

#import "DownloadSession.h"

#import "Stack.h"
#import "DownloadTaskInfo.h"

/**
 Constant to indicate cancelled task.
 */
static NSInteger const kCancelled = -999;

@interface DownloadSession () <NSURLSessionDownloadDelegate>

/**
 Stack to store the pending downloads.
 */
@property (nonatomic, strong) Stack *downloadStack;

/**
 Current download.
 */
@property (nonatomic, strong) DownloadTaskInfo *inProgressDownload;

/**
 Session Object.
 */
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation DownloadSession

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        [configuration setHTTPMaximumConnectionsPerHost:1];
        
        self.session = [NSURLSession sessionWithConfiguration:configuration
                                                     delegate:self
                                                delegateQueue:[NSOperationQueue mainQueue]];
        
        _downloadStack = [[Stack alloc] init];
    }
    
    return self;
}

+ (DownloadSession *)downloadSession
{
    static DownloadSession *downloadSession = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
                  {
                      NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
                      
                      [configuration setHTTPMaximumConnectionsPerHost:100];
                      
                      downloadSession = [[self alloc] init];
                  });
    
    return downloadSession;
}

#pragma mark - ScheduleDownload

+ (void)scheduleDownloadFromURL:(NSURL *)url
        completionBlock:(void (^)(DownloadTaskInfo *downloadTask, NSURL *location, NSError *error))completionHandler
{
    DownloadTaskInfo *task = [[DownloadTaskInfo alloc] initWithFileTitle:[url absoluteString]
                                                             URL:url
                                                 completionBlock:completionHandler];
    
    [[DownloadSession downloadSession].downloadStack push:task];
    
    [DownloadSession resumeDownloads];
}

#pragma mark - ForceDownload

+ (void)forceDownloadFromURL:(NSURL *)url
             completionBlock:(void (^)(DownloadTaskInfo *downloadTask, NSURL *location, NSError *error))completionHandler
{
    [DownloadSession pauseDownloads];
    
    [DownloadSession scheduleDownloadFromURL:url
                             completionBlock:completionHandler];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    if (self.inProgressDownload.task.taskIdentifier == downloadTask.taskIdentifier)
    {
        if (self.inProgressDownload.completionHandler)
        {
            self.inProgressDownload.completionHandler(self.inProgressDownload, location, nil);
        }
        
        self.inProgressDownload = nil;
        
        [DownloadSession resumeDownloads];
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if (self.inProgressDownload)
    {
        self.inProgressDownload.downloadProgress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        [self.delegate didUpdateProgress:self.inProgressDownload];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error &&
        error.code != kCancelled)
    {
        //  Handle error
        NSLog(@"task: %@ Error: %@", @(task.taskIdentifier), error);
        [DownloadSession resumeDownloads];
    }
}

#pragma mark - Cancel

+ (void)cancelDownloads
{
    [[DownloadSession downloadSession].inProgressDownload.task cancel];
    [DownloadSession downloadSession].inProgressDownload = nil;
    [[DownloadSession downloadSession].downloadStack clear];
}

#pragma mark - Resume

+ (void)resumeDownloads
{
    if (![DownloadSession downloadSession].inProgressDownload)
    {
        [DownloadSession downloadSession].inProgressDownload = [[DownloadSession downloadSession].downloadStack pop];
    }
    
    if ([DownloadSession downloadSession].inProgressDownload &&
        ![DownloadSession downloadSession].inProgressDownload.isDownloading)
    {
        if ([DownloadSession downloadSession].inProgressDownload.taskResumeData.length > 0)
        {
            NSLog(@"Resuming task - %@", [DownloadSession downloadSession].inProgressDownload.taskIdentifier);
            
            [DownloadSession downloadSession].inProgressDownload.task = [[DownloadSession downloadSession].session downloadTaskWithResumeData:[DownloadSession downloadSession].inProgressDownload.taskResumeData];
        }
        else
        {
            if ([DownloadSession downloadSession].inProgressDownload.task.state == NSURLSessionTaskStateCompleted)
            {
                //we cancelled this operation before it actually started
                [DownloadSession downloadSession].inProgressDownload.task = [[DownloadSession downloadSession].session downloadTaskWithURL:[DownloadSession downloadSession].inProgressDownload.url];
            }
            else
            {
                NSLog(@"Starting task - %@", [DownloadSession downloadSession].inProgressDownload.taskIdentifier);
            }
        }
        
        [DownloadSession downloadSession].inProgressDownload.isDownloading = YES;
        [[DownloadSession downloadSession].inProgressDownload.task resume];
        
        [[DownloadSession downloadSession].delegate didResumeDownload:[DownloadSession downloadSession].inProgressDownload];
    }
}

#pragma mark - Pause

+ (void)pauseDownloads
{
    if ([DownloadSession downloadSession].inProgressDownload)
    {
         NSLog(@"Pausing task - %@", [DownloadSession downloadSession].inProgressDownload.taskIdentifier);
        
        [[DownloadSession downloadSession].inProgressDownload pause];
        
        [[DownloadSession downloadSession].downloadStack push:[DownloadSession downloadSession].inProgressDownload];
        
        [DownloadSession downloadSession].inProgressDownload = nil;
    }
}

#pragma mark - NSURLSessionDownloadTask

- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)url
{
    return [[DownloadSession downloadSession].session downloadTaskWithURL:url];
}

@end
