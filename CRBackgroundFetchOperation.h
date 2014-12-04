//
//  CRBackgroundFetchOperation.h
//  Cloakroom
//
//  Created by Mark Ramotowski on 28/11/2014.
//  Copyright (c) 2014 Mark Ramotowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRBackgroundFetchOperation : NSOperation

@property (nonatomic, strong) NSDate * date;

@property (nonatomic, strong) NSString * venueId;

@end
