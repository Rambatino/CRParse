//
//  CRPhotoService.h
//  Cloakroom
//
//  Created by Mark Ramotowski on 30/11/2014.
//  Copyright (c) 2014 Mark Ramotowski. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface CRPhotoService : NSObject

// save the picture to the managed object
+ (void) savePhotoToObject:(NSManagedObject*) object withPhotoUrl:(NSString*) photoUrl withKey:(NSString*) key;

@end
