//
//  BackgroundDataMethods.h
//  Cloakroom
//
//  Created by Mark Ramotowski on 30/08/2014.
//  Copyright (c) 2014 Mark Ramotowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRBackgroundFetchHandler : NSObject {
    BOOL _accessedElsewhere;
}

// Constantly called to search in the background for un-uploaded data, until stop is called

//- (void) startUploadChecker;
//- (void) stopUploadChecker;

// Constantly checking for new data, until stop is called

- (void) startCheckingForNewData;
- (void) stopCheckingForNewData;

- (void) checkForNewData:(NSTimer *) timer;

@property BOOL accessedElsewhere;
@property NSDate *updateDataCallDate;
//- (void) checkParseDataModelForNewDataWithNewDataCompletion:(void (^)(NSInteger applicationCount)) completion;

@property (nonatomic, strong) NSString * venueId;
@property (nonatomic, strong) NSDate * date;

@end
