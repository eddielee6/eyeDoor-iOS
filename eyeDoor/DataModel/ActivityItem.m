//
//  ActivityItem.m
//  eyeDoor
//
//  Created by Eddie Lee on 12/04/2013.
//  Copyright (c) 2013 Eddie Lee. All rights reserved.
//

#import "ActivityItem.h"


@implementation ActivityItem

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ActivityItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ActivityItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ActivityItem" inManagedObjectContext:moc_];
}

@dynamic dateReceived;
@dynamic message;
@dynamic imagePath;
@dynamic type;

@end
