//
//  CRDataService.h
//  Cloakroom
//
//  Created by Mark Ramotowski on 19/11/2014.
//  Copyright (c) 2014 Mark Ramotowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CRData <NSObject>

@required

@end

@interface CRDataService : NSObject

// save the object to parse
+ (void) saveObject:(NSDictionary*) object ofClassWithName:(NSString*) class toParse:(CRSuccessBlock) completion;

// save the object locally
+ (void) saveObject:(NSDictionary*) object;

// save many objects locally and then save the current context
+ (void) saveArrayOfObjects:(NSArray*) arrayOfDictionaries;

// extract data from graph
+ (NSArray*) returnArrayOfManagedObjectsForClass:(NSString*) className thatMatchPredicate:(NSPredicate*) predicate;

// extract data from graph with format
+ (NSArray*) returnArrayOfFormattedObjectsForClass:(NSString*) className thatMatchPredicate:(NSPredicate*) predicate;

// save the context to disk
+ (void) saveToDisk;

@end
