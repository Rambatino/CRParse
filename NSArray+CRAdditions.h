//
//  NSArrayf.h
//  Cloakroom
//
//  Created by Mark Ramotowski on 28/11/2014.
//  Copyright (c) 2014 Mark Ramotowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (CRAdditions)

+ (NSArray*) arrayWithLength:(NSInteger) length withRepeatedObject:(id) object;

+ (NSArray*) arrayWithPropertiesOfObjects:(NSArray*) objects;

@end
