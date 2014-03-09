//
//  ActivityItem.h
//  eyeDoor
//
//  Created by Eddie Lee on 12/04/2013.
//  Copyright (c) 2013 Eddie Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ActivityItem : NSManagedObject

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;

@property (nonatomic, retain) NSDate * dateReceived;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSString * type;

@end
