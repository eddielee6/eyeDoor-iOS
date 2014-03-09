//
//  EyeDoorDataModel.h
//  eyeDoor
//
//  Created by Eddie Lee on 12/04/2013.
//  Copyright (c) 2013 Eddie Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EyeDoorDataModel : NSObject

+ (id)sharedDataModel;

@property (nonatomic, readonly) NSManagedObjectContext *mainContext;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString *)modelName;
- (NSString *)pathToModel;
- (NSString *)storeFilename;
- (NSString *)pathToLocalStore;

@end
