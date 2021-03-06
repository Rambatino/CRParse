//
//  NSDictionary+CRAdditions.m
//  Cloakroom
//
//  Created by Mark Ramotowski on 28/11/2014.
//  Copyright (c) 2014 Mark Ramotowski. All rights reserved.
//

#import "NSDictionary+CRAdditions.h"
#import <objc/runtime.h>

@implementation NSMutableDictionary (CRAdditions)

+ (NSMutableDictionary *) dictionaryWithPropertiesOfObject:(id) obj byRemovingKeys:(NSArray*) keys {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    unsigned count;
    
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
    while (count --> 0) {
        
        NSString *key = [NSString stringWithUTF8String:property_getName
                         (properties[count])];
        
        // Must check if the object exists and the key isn't in the avoidance keys
        if ([obj valueForKey:key] && ![keys containsObject:key] && ![[obj valueForKey:key] isKindOfClass:[NSArray class]] && ![[obj valueForKey:key] isKindOfClass:[NSManagedObject class]]) {
            
            [dictionary setObject:[obj valueForKey:key] forKey:key];
            
        }
        
    }
    
    free(properties); 
    
    return dictionary;
}

+ (NSMutableDictionary *) dictionaryWithPropertiesOfParseObject:(PFObject*) obj {
    
    NSString *(^convertParseObjectToLocalClass)(PFObject*);
    convertParseObjectToLocalClass = ^NSString*(PFObject *parseObject) {
        
        NSString *className = parseObject.parseClassName;
        
        if ([className isEqualToString:@"_User"]) {
            
            // Changing the _User to local name
            className = @"CRMember";
        }
        
        return className;
    };
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    unsigned count;

    NSString *className = convertParseObjectToLocalClass(obj);
    
    // set the class name in here
    dictionary[@"class"]  = className.copy;
    
    // must change the CR to PF so that it points to the right class
    className = [className stringByReplacingOccurrencesOfString:@"CR" withString:@"PF" options:NSLiteralSearch range:NSMakeRange(0, className.length)];
    
    objc_property_t *properties = class_copyPropertyList(NSClassFromString(className), &count);
    
    while (count --> 0) {
        
        NSString *key = [NSString stringWithUTF8String:property_getName
                         (properties[count])];
                
        // check if there is a pointer to a parse object - will potentially have to handle arrays as well
        if ([[obj valueForKey:key] isKindOfClass:[PFObject class]] && [[obj valueForKey:key] objectId]) {
                        
            // create the pointer that will link the two managed objects
            NSString *idPointer = [key stringByAppendingString:@"Id"];

            dictionary[idPointer] = [[obj valueForKey:key] objectId];
    
            // Must check if the object exists and the key isn't in the avoidance keys
        } else if ([obj valueForKey:key] && ![[obj valueForKey:key] isKindOfClass:[NSArray class]] && ![[obj valueForKey:key] isKindOfClass:[NSManagedObject class]]) {
            
            dictionary[key] = [obj valueForKey:key];
            
        }
        
    }
    
    free(properties);
    
    return dictionary;

}

@end
