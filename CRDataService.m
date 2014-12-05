//
//  CRDataService.m
//  Cloakroom
//
//  Created by Mark Ramotowski on 19/11/2014.
//  Copyright (c) 2014 Mark Ramotowski. All rights reserved.
//

#import "CRDataService.h"

@implementation CRDataService

// save the object to parse
+ (void) saveObject:(NSDictionary*) object ofClassWithName:(NSString*) class toParse:(CRSuccessBlock) completion {
    
    PFObject *parseObject;
    
    // Determine whether the object exists on parse or not already
    if (object[@"id"]) {
        
        // The object has an id on parse and thus is not new
        parseObject = [PFObject objectWithoutDataWithClassName:class objectId:object[@"id"]];
    
    } else {
        
        // the object does not exist on parse already and thus is a new object
        parseObject = [PFObject objectWithClassName:class];
        
    }
    
    // set the respective keys on the parse object
    [parseObject setValuesForKeysWithDictionary:object];
    
    // save the parse object locally for immediate effect
    // but must save the managed object id so that the same object can have its id updated afterwards

    // even though you have a managed object here, it is not in sync with the persistent store coordinator
    
    // create the context
    NSManagedObjectContext * context = [CRCoreDataStore newMainQueueContext];
    
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithPropertiesOfParseObject:parseObject];
    
    NSManagedObjectID * managedObjectID = [self addObject:dictionary toContext:context withClassName:dictionary[@"class"]];
    
    // save the context
    [self saveContext:context withCompletion:^(NSError *error) {
        
        // fire off the save notification when the parent cotext (default) now has the data
        [CRNotificationService newActivity];
        
    }];
    
    [parseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
         
         if (error) {
             
             // handle parse error approriately
             NSLog(@"An error has occured: %@ {%s}", error.userInfo, __PRETTY_FUNCTION__);
             
         } else {
             // create new context
             NSManagedObjectContext * inBlockContext = [CRCoreDataStore newMainQueueContext];
             
             // fetch the object
             NSManagedObject * managedObject = [inBlockContext objectWithID:managedObjectID];
             
             // determine whether that object is to be deleted
             if ([[context valueForKey:@"toBeDeleted"] boolValue]) {
                 
                 // succesful save on the parse server can now retrieve the correct object and set its id
                 [self saveIdentification:parseObject.objectId toObject:managedObject inContext:context];
                 
             }
            
         }
         
         // call the completion handler
         SAFE_FUNCTION(completion, succeeded, error);
         
     }];
    
}

+ (void) saveObject:(NSDictionary*) object {

    // managed object context
    NSManagedObjectContext *context = [CRCoreDataStore newPrivateQueueContext];
    
    [self addObject:object toContext:context withClassName:object[@"class"]];
    
    [self saveContext:context withCompletion:nil];

}

+ (void) saveArrayOfObjects:(NSArray*) arrayOfDictionaries {
    
    // managed object context
    NSManagedObjectContext *context = [CRCoreDataStore newPrivateQueueContext];
    
    NSInteger count = arrayOfDictionaries.count;
    
    while (count -- > 0) {
        
        NSAssert2(arrayOfDictionaries[count][@"class"], @"The object does not contain a class specifier %s\nobject = %@", __PRETTY_FUNCTION__, arrayOfDictionaries[count]);

        [self addObject:arrayOfDictionaries[count] toContext:context withClassName:arrayOfDictionaries[count][@"class"]];
    }
    
    [self saveContext:context withCompletion:nil];

}

// Private

+ (NSManagedObjectID*) addObject:(NSDictionary*) object toContext:(NSManagedObjectContext*) context withClassName:(NSString*) className {
    
    // must check if the object already exists on the system, if not then add it
    NSAssert1(object[@"id"] || object[@"eventId"], @"Object must contain an id or an event id in which to search against with object %@", object);
    
    NSArray* (^createFetchRequest)(NSString*,NSString*) = ^NSArray*(NSString*id,NSString*class) {
        
        NSAssert1(class, @"No class was provided in which to query the data base. With object: %@", object);

        // fetch the correct entity
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:class inManagedObjectContext:context];
        
        // create the predicate
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id==%@", id];
        
        
        NSFetchRequest *request = [NSFetchRequest new];
        
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        // Check if the object exists
        NSError *error;
        return [context executeFetchRequest:request error:&error];
    };
    
    __unsafe_unretained __block void (^assignPropertyValues)(NSDictionary*, NSManagedObject*);
    
    assignPropertyValues = ^void(NSDictionary * keyValuePairs, NSManagedObject * object) {
        
        // loop through the key value pairs
        [keyValuePairs enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            // check if the value is an array
            if ([obj isKindOfClass:[NSArray class]]) {
                
                __block NSMutableArray * objectsArray = @[].mutableCopy;
                
                [obj enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    // wrong fetch here - should fetch all applications that are linked to that guestlist no?
                    NSArray *array = createFetchRequest(obj[@"id"], obj[@"class"]);
                    
                    if (array.count == 0) {
                        
                        // Object does not exist
                        // create the object and save them
                        __block NSManagedObject *newObject = [NSEntityDescription
                                                              insertNewObjectForEntityForName:obj[@"class"]
                                                              inManagedObjectContext:context];
                        
                        assignPropertyValues(obj, newObject);
                        
                        [context insertObject:newObject];
                        
                        [objectsArray addObject:newObject];
                        
                    } else {
                        
                        // Must update the object with new information
                        __block NSManagedObject *oldObject = array.firstObject;
                        
                        assignPropertyValues(obj, oldObject);
                        
                        [objectsArray addObject:oldObject];
                    }
                    
                }];
                
                // now have an array of managed objects
                [object setValue:[NSSet setWithArray:objectsArray] forKey:key];
                
            } else if ([obj isKindOfClass:[NSDictionary class]]) {
                
                // find the managed object context
                NSArray *array = createFetchRequest(obj[@"id"], obj[@"class"]);
                
                // save it
                if (array.count == 0) {
                    
                    __block NSManagedObject *newObject = [NSEntityDescription
                                                          insertNewObjectForEntityForName:obj[@"class"]
                                                          inManagedObjectContext:context];
                    
                    assignPropertyValues(obj, newObject);
                    
                    [context insertObject:newObject];
                    
                } else {
                    
                    // Must update the object with new information
                    __block NSManagedObject *oldObject = array.firstObject;
                    
                    assignPropertyValues(obj, oldObject);
                                        
                }
                
                
            } else {
                
                // the value is core and therfore set it
                [object setValue:obj forKey:key];
                
            }
            
        }];
    };
    
    // intialise to empty
    NSArray *array = @[];
    
    if(object[@"id"]) {
        
        // if there is an object id, attempt to find it! If not, then just save a new object and set its keys
        array = createFetchRequest(object[@"id"], className);
    
    }
    
    if (array.count == 0) {
        
        // User does not exist
        // create the user and save them
        __block NSManagedObject *newObject = [NSEntityDescription
                                      insertNewObjectForEntityForName:className
                                      inManagedObjectContext:context];
        
        assignPropertyValues(object, newObject);
        
        [context insertObject:newObject];

        // need to set the permananet id so that it can be fetched after the parse object save
        [context obtainPermanentIDsForObjects:@[newObject] error:nil];
        
        return newObject.objectID;
        
    } else {
        
        // Must update the object with new information
        __block NSManagedObject *oldObject = array.firstObject;
        
        assignPropertyValues(object, oldObject);
        
        return oldObject.objectID;
    }

}

+ (NSArray*) returnArrayOfManagedObjectsForClass:(NSString*) className thatMatchPredicate:(NSPredicate*) predicate {
    
    NSArray* (^createFetchRequest)(NSString*,NSPredicate*) = ^NSArray*(NSString*class,NSPredicate*predicate) {
        
        // fetch the correct entity
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:class inManagedObjectContext:[CRCoreDataStore defaultPrivateQueueContext]];
        
        // create the request
        NSFetchRequest *request = [NSFetchRequest new];
        
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        // Check if the object exists
        NSError *error;
                
        return [[CRCoreDataStore defaultPrivateQueueContext] executeFetchRequest:request error:&error];
    
    };
    
    return createFetchRequest(className, predicate);
    
}

+ (NSArray*) returnArrayOfFormattedObjectsForClass:(NSString*) className thatMatchPredicate:(NSPredicate*) predicate {
    
    return [NSArray arrayWithPropertiesOfObjects:[self returnArrayOfManagedObjectsForClass:className thatMatchPredicate:predicate]];
    
}


#pragma mark -
#pragma mark Private Methods

+ (void) saveIdentification:(NSString*) id toObject:(NSManagedObject*) managedObject inContext:(NSManagedObjectContext*) context {
    
    // set the value
    [managedObject setValue:id forKey:@"id"];
    

    // save the context that this object currently resides in and then the parent to persist it
    
    [self saveContext:context withCompletion:^(NSError *error) {
       
//        [self saveContext:context.parentContext withCompletion:nil];

    }];
}

+ (void) saveContext:(NSManagedObjectContext*) context withCompletion:(CRContextSave) completion {
 
    __block NSError *error;
    
    if ([context hasChanges]) {
        [context performBlock:^{
            [context save:&error];

            SAFE_FUNCTION(completion, error);

        }];
    } else {
        
        NSLog(@"It does not have any changes :s");
        
    }
    
}

+ (void) saveToDisk {
    
    NSManagedObjectContext *parentContext = [CRCoreDataStore defaultPrivateQueueContext].parentContext;
    
    [self saveContext:parentContext withCompletion:^(NSError *error) {
       
        NSLog(@"The parent context has been saved and therefore the changes have been commited to idisk");
        
    }];
    
}

@end
