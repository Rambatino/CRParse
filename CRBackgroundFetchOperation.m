//
//  CRBackgroundFetchOperation.m
//  Cloakroom
//
//  Created by Mark Ramotowski on 28/11/2014.
//  Copyright (c) 2014 Mark Ramotowski. All rights reserved.
//

#import "CRBackgroundFetchOperation.h"
#import "CRParseService.h"
#import "CRDataService.h"

@implementation CRBackgroundFetchOperation

- (void) main {
    
    // check if it has been cancelled prematurely
    if (![self isCancelled] && _date && _venueId) {
    
        // Must query the server for data
        [CRParseService queryParseForVenueDataWithDate:_date
                                               atVenue:_venueId
                                        withCompletion:^(id object, NSError *error) {
            
            if (error) {
                
                // handle the error
                NSLog(@"Error retrieving data %s\n%@", __PRETTY_FUNCTION__, error);
                
            } else {
//                NSLog(@"data = %@", object);

                NSDate *date = [NSDate date];
                // save the JSON locally
                [CRDataService saveObject:object[@"event"]];
                
                // must also save all the members associated with this event
                [CRDataService saveArrayOfObjects:object[@"members"]];
                
                NSLog(@"Time to save venue data = %f", [[NSDate date]timeIntervalSinceDate:date]);
                
                // post notification that new data has arrived
                [CRNotificationService freshServerData];
                
            }
        
        }];
    
    }
    
}

@end
