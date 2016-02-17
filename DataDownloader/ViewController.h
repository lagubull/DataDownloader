//
//  ViewController.h
//  DataDownloader
//
//  Created by Javier Laguna on 15/02/16.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) IBOutlet UILabel *downloadInProgressLabel;

@end

