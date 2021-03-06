//
//  CRManagedObject.m
//  Cloakroom
//
//  Created by Mark Ramotowski on 29/11/2014.
//  Copyright (c) 2014 Mark Ramotowski. All rights reserved.
//

#import "CRManagedObject.h"
#import "CRPhotoService.h"

@implementation CRManagedObject

- (void) setValue:(id)value forUndefinedKey:(NSString *)key {
    
    if ([key rangeOfString:@"Id"].location != NSNotFound && ![value isEqualToString:@""]) {
        
        NSString *relationship = [key stringByReplacingOccurrencesOfString:@"Id" withString:@""];
        
        NSString *class = relationship.copy;
        
        if ([class isEqualToString:@"member"] || [class isEqualToString:@"staff"] || [class isEqualToString:@"host"] || [class isEqualToString:@"memberHost"]) {
            
            class = @"CRMember";
            
        } else if([class isEqualToString:@"venue"]) {
            
            class = @"CRVenue";
        } else if ([class isEqualToString:@"event"]) {
            
            class = @"CREvent";
        }
        
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:class inManagedObjectContext:self.managedObjectContext];
        
        // create the predicate
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id==%@", value];
        
        
        NSFetchRequest *request = [NSFetchRequest new];
        
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        // Check if the object exists
        NSError *error;
        NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        NSManagedObject *object;
         
        NSAssert1(relationship, @"Relationship is undefined {%@}", key);
        
        if (array.count == 0) {
           
            object = [NSEntityDescription insertNewObjectForEntityForName:class
                                                   inManagedObjectContext:self.managedObjectContext];
            
            [object setValue:value forKey:@"id"];
            
            [self.managedObjectContext insertObject:object];
            
            // associate it with this class
            [self setValue:object forKey:relationship];
            
        } else if (array) {
            
            object = array.firstObject;

            // associate it with this class
            [self setValue:object forKey:relationship];
            
        }
        
    } else {
        if (![key isEqualToString:@"class"]) {

            // log a key that is not expected
            NSLog(@"key not found = %@ with value = %@ for class %@", key, value, self.entity.name);

        }
    }
        
    return;

}

- (id) valueForUndefinedKey:(NSString *)key {

    return nil;
    
}

- (void) setValue:(id)value forKey:(NSString *)key {

    if ([key isEqualToString:@"photoUrl"]) {
        
        // handle saving the photo to the object
        [CRPhotoService savePhotoToObject:self withPhotoUrl:value withKey:@"photo"];
    
    }

    [super setValue:value forKey:key];

}

@end
