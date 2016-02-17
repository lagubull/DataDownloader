//
//  Stack.m
//  DataDownloader
//
//  Created by Javier Laguna on 10/02/2016.
//  Copyright © 2016 Medigarage Studios LTD. All rights reserved.
//

#import "Stack.h"

@interface Stack ()

@property (nonatomic, assign, readwrite) NSInteger count;

@property (nonatomic, strong) NSMutableArray* objectsArray;

@end

@implementation Stack

- (instancetype)init
{
    self = [super init];

    if(self)
    {
        _objectsArray = [[NSMutableArray alloc] init];
        _count = 0;
    }
    
    return self;
}


- (void)push:(id)anObject
{
    [self.objectsArray addObject:anObject];
    self.count = self.objectsArray.count;
}

- (id)pop
{
    id obj = nil;
    
    if (self.objectsArray.count > 0)
    {
        obj = [self.objectsArray lastObject];
        
        [self.objectsArray removeLastObject];
        self.count = self.objectsArray.count;
    }
    
    return obj;
}

- (void)clear
{
    [self.objectsArray removeAllObjects];
    self.count = 0;
}

- (void)dealloc
{
    self.objectsArray = nil;
}

@end
