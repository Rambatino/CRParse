//
//  NSArrayf.m
//  Cloakroom
//
//  Created by Mark Ramotowski on 28/11/2014.
//  Copyright (c) 2014 Mark Ramotowski. All rights reserved.
//

#import "NSArray+CRAdditions.h"

@implementation NSArray (CRAdditions)

+ (NSArray*) arrayWithLength:(NSInteger) length withRepeatedObject:(id) object {
    
    NSMutableArray *mutableArray = @[].mutableCopy;
    
    while (length -- > 0) {
        [mutableArray addObject:object];
    }
    
    return [NSArray arrayWithArray:mutableArray];
}

+ (NSArray*) arrayWithPropertiesOfObjects:(NSArray*) objects {
    
    NSMutableArray *array = @[].mutableCopy;
    
    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       
        NSMutableDictionary *propertiesDictionary = [NSMutableDictionary dictionaryWithPropertiesOfObject:obj byRemovingKeys:@[]];
        
        [array addObject:propertiesDictionary];
        
    }];
    
    return array;
}

@end
