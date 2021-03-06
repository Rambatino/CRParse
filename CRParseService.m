//
//  CRParseService.m
//  Cloakroom
//
//  Created by Mark Ramotowski on 27/11/2014.
//  Copyright (c) 2014 Mark Ramotowski. All rights reserved.
//

#import "CRParseService.h"

@implementation CRParseService

+ (void) queryParseForVenueDataWithDate:(NSDate*) date atVenue:(NSString*) venueId withCompletion:(CRIdResultBlock) completion {
    
    [PFCloud callFunctionInBackground:@"retrieveVenueData"
                       withParameters:@{
                                        @"venueId" : venueId,
                                        @"eventDate" : date
                                        }
                                block:^(id object, NSError *error) {
        
        // fire the completion handler off on another thread
                                    NSLog(@"The object = %@", object);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

            SAFE_FUNCTION(completion, object, error);
        
        });
                                    
    }];
    
}

@end