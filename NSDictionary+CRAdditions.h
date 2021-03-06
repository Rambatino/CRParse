//
//  NSDictionary+CRAdditions.h
//  Cloakroom
//
//  Created by Mark Ramotowski on 28/11/2014.
//  Copyright (c) 2014 Mark Ramotowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (CRAdditions)

+ (NSMutableDictionary *) dictionaryWithPropertiesOfObject:(id) obj byRemovingKeys:(NSArray*) keys;

// in case dealing with parse object
+ (NSMutableDictionary *) dictionaryWithPropertiesOfParseObject:(PFObject*) obj;

@end
