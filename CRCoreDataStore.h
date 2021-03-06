//
//  TBCoreDataStoreS2.h
//  TBCoreDataStore
//
//  Created by Theodore Calmes on 1/17/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import "NSFileManager+TBDirectories.h"
#import "NSManagedObjectID+TBString.h"

@import CoreData;
@import Foundation;

@interface CRCoreDataStore : NSObject

+ (instancetype)defaultStore;

+ (NSManagedObjectContext *)newMainQueueContext;
+ (NSManagedObjectContext *)defaultPrivateQueueContext;
+ (NSManagedObjectContext *)newPrivateQueueContext;

+ (NSManagedObjectID *)managedObjectIDFromString:(NSString *)managedObjectIDString;

@end
