//
//  ViewController.m
//  DataDownloader
//
//  Created by Javier Laguna on 15/02/16.
//

#import "ViewController.h"

#import "DownloadSession.h"
#import "DownloadTaskInfo.h"

@interface ViewController () <DownloadSessionDelegate>

/**
 Indicates the progress of the current download.
 */
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation ViewController

#pragma mark - ViewLifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [DownloadSession downloadSession].delegate = self;
    
    [self.progressView setProgress:0
                          animated:NO];
}

#pragma mark - ButtonActions

- (IBAction)downloadFile:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"https://s3-eu-west-1.amazonaws.com/unii-fling-dev/original_7b116288baa584b40eb83ba1728f6764.mp4"];
    
    [DownloadSession forceDownloadFromURL:url
                          completionBlock:^(DownloadTaskInfo *downloadTask, NSURL *location, NSError *error)
     {
         NSLog(@"Finsihed task - %@", downloadTask.taskIdentifier);
     }];
}

- (IBAction)pauseDownload:(id)sender
{
    [DownloadSession pauseDownloads];
}

- (IBAction)resumeDownload:(id)sender
{
    [DownloadSession resumeDownloads];
}

- (IBAction)cancelDownload:(id)sender
{
    [DownloadSession cancelDownloads];
    
    self.downloadInProgressLabel.text = @"";
    self.progressView.progress = 0.0f;
}

#pragma mark - DownloadSessionDelegate

- (void)didUpdateProgress:(DownloadTaskInfo *)downloadTaskInfo
{
    self.progressView.progress = downloadTaskInfo.downloadProgress;
}

- (void)didResumeDownload:(DownloadTaskInfo *)downloadTaskInfo
{
    self.downloadInProgressLabel.text = [NSString stringWithFormat:@"task %@", downloadTaskInfo.taskIdentifier];
}

@end
