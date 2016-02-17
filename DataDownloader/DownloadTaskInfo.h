//
//  DownloadTask.h
//  DataDownloader
//
//  Created by Javier Laguna on 10/02/2016.
//  Copyright © 2016 Medigarage Studios LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Represents a download task and its metadata.
 */
@interface DownloadTaskInfo : NSObject

/**
 Data already downloaded.
 */
@property (nonatomic, strong) NSData *taskResumeData;

/**
 Progress of the download.
 */
@property (nonatomic, assign) double downloadProgress;

/**
 Indicates whethere the task is executing.
 */
@property (nonatomic, assign) BOOL isDownloading;

/**
 Indicates where the download has finished.
 */
@property (nonatomic, assign) BOOL downloadComplete;

/**
 The task itself.
 */
@property (nonatomic, strong) NSURLSessionDownloadTask *task;

/**
 Identifies the object.
 */
@property (nonatomic, copy) NSString *taskIdentifier;

/**
 Block to be executed upon finishing.
 */
@property (nonatomic, copy) void (^completionHandler)(DownloadTaskInfo *downloadTask, NSURL *location, NSError *error);

/**
 Path to be downloaded.
 */
@property (nonatomic, strong) NSURL *url;

/**
 Creates a new DownloadTaskInfo object.
 
 @param title - used to identify the task.
 @param url - URL task will download from.
 @param completionBlock -  Block to be executed upon finishing.
 
 @return Instance of the class.
 */
- (instancetype)initWithFileTitle:(NSString *)title
                   URL:(NSURL *)url
                  completionBlock:(void (^)(DownloadTaskInfo *downloadTask, NSURL *location, NSError *error))completionHandler;

/**
 Stops the task and stores the progress.
 */
- (void)pause;

@end
