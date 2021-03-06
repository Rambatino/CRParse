//
//  CRParseService.h
//  Cloakroom
//
//  Created by Mark Ramotowski on 27/11/2014.
//  Copyright (c) 2014 Mark Ramotowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRParseService : NSObject

// Get the venue's data model that is currently in the Cloud function: retrieveHostData
+ (void) queryParseForVenueDataWithDate:(NSDate*) date atVenue:(NSString*) venueId withCompletion:(CRIdResultBlock) completion;

@end
