//
//  Stack.h
//  DataDownloader
//
//  Created by Javier Laguna on 10/02/2016.
//  Copyright © 2016 Medigarage Studios LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stack : NSObject

@property (nonatomic, assign, readonly) NSInteger count;

- (void)push:(id)anObject;

- (id)pop;

- (void)clear;

@end
