//
//  BackgroundDataMethods.m
//  Cloakroom
//
//  Created by Mark Ramotowski on 30/08/2014.
//  Copyright (c) 2014 Mark Ramotowski. All rights reserved.
//

#import "CRBackgroundFetchHandler.h"

// Time interval definitions

#import "CRBackgroundFetchOperation.h"

#define uploadCheckingTimeSeperator 60*1
#define updatingDataTimeSeperator 60

@interface CRBackgroundFetchHandler ()

@property BOOL checkingServerData;
@property NSTimer *dataCheckingTimer;
@property NSTimer *uploadCheckingTimer;

// Background data threading

@property NSOperationQueue * queue;

@property CRBackgroundFetchOperation * checkingForData;

@end


@implementation CRBackgroundFetchHandler

- (id) init {
    self = [super init];
    if (self) {
        NSLog(@"fetch handler has been initialised");
    }
    return self;
}

- (void) startCheckingForNewData {
    if(self.checkingForData) {
        self.checkingForData = nil;
    }
    self.checkingForData = [CRBackgroundFetchOperation new];
    self.checkingForData.date = _date;
    self.checkingForData.venueId = _venueId;
    
    if(!self.queue) {
        self.queue = [NSOperationQueue new];
    }
    if(![self.queue.operations containsObject:self.checkingForData]) {
        [self.queue addOperation:self.checkingForData];
    }
    if(!self.dataCheckingTimer) {
        self.dataCheckingTimer = [NSTimer timerWithTimeInterval:updatingDataTimeSeperator
                                                         target:self
                                                       selector:@selector(checkForNewData:)
                                                       userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.dataCheckingTimer forMode:NSRunLoopCommonModes];
    }
}

- (void) stopCheckingForNewData {
    [self.queue cancelAllOperations];    
}

- (void) checkForNewData:(NSTimer *) timer {
    if(!self.accessedElsewhere) {
        [self startCheckingForNewData];
    }
}

// Handling whether the data is being accessed elsewhere

- (void) setAccessedElsewhere:(BOOL)accessedElsewhere {
    _accessedElsewhere = accessedElsewhere;
    [self stopCheckingForNewData];
    if (!accessedElsewhere) {
        [self startCheckingForNewData];
    }
}

- (BOOL) accessedElsewhere {
    return _accessedElsewhere;
}


@end
