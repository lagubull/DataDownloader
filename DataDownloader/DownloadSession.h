//
//  DownloadSession.h
//  DataDownloader
//
//  Created by Javier Laguna on 10/02/2016.
//  Copyright © 2016 Medigarage Studios LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DownloadTaskInfo;

/**
 Protocol to indicate the status of the downloads.
 */
@protocol DownloadSessionDelegate <NSObject>

- (void)didResumeDownload:(DownloadTaskInfo *)downloadTaskInfo;

- (void)didUpdateProgress:(DownloadTaskInfo *)downloadTaskInfo;

@end

/**
 Defines a session with custom methods to download.
 */
@interface DownloadSession : NSObject

/**
 Stop and remove all the pending downloads without executing the completion block.
 */
+ (void)cancelDownloads;

/**
 Resume or starts the next pending download if it is not already executing.
 */
+ (void)resumeDownloads;

/**
 Stop the current downlad and saves it back in the queue without triggering a new download.
 */
+ (void)pauseDownloads;

/**
 Creates an instance od DownloadSession
 
 @return DownloadSession - instance of self.
 */
+ (DownloadSession *)downloadSession;

/**
 Adds a downloading task to the stack.
 
 @param URL - path to download.
 @param completionBlock - to be executed when the task finishes.
 */
+ (void)scheduleDownloadFromURL:(NSURL *)url
                completionBlock:(void (^)(DownloadTaskInfo *downloadTask, NSURL *location, NSError *error))completionHandler;

/**
 Stops the current download and adds it to the stack, the it begins executing this new download.
 
 @param URL - path to download.
 @param completionBlock - to be executed when the task finishes.
 */
+ (void)forceDownloadFromURL:(NSURL *)url
             completionBlock:(void (^)(DownloadTaskInfo *downloadTask, NSURL *location, NSError *error))completionHandler;

/**
 Creates a download task to download the contents of the given URL.
 
 @param URL - path to download.
 */
- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)url;

/**
 Delegate for the DOwnloadSessionDelegate class.
 */
@property (nonatomic, weak) id<DownloadSessionDelegate>delegate;

@end
