//
//  eyeDoorAppDelegate.m
//  eyeDoor
//
//  Created by Eddie Lee on 22/02/2013.
//  Copyright (c) 2013 Eddie Lee. All rights reserved.
//

#import "AppDelegate.h"
#import "ActivityItem.h"
#import "EyeDoorDataModel.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation AppDelegate {
    SystemSoundID _alertId;
    SystemSoundID _motionId;

    UINavigationController *navigationController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    NSLog(@"Launch options: %@", launchOptions);

    NSString *alertSoundPath = [[NSBundle mainBundle] pathForResource:@"alert" ofType:@"caf"];
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain([NSURL fileURLWithPath: alertSoundPath]), &_alertId);

    NSString *bellSoundPath = [[NSBundle mainBundle] pathForResource:@"doorbell" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain([NSURL fileURLWithPath: bellSoundPath]), &_motionId);
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Notification: %@", userInfo);

    if(application.applicationState == UIApplicationStateActive ) { 
        if([[userInfo valueForKeyPath:@"type"] isEqualToString:@"button"]) {
            AudioServicesPlaySystemSound (_motionId);
        } else if([[userInfo valueForKeyPath:@"type"] isEqualToString:@"motion"]) {
            AudioServicesPlaySystemSound (_alertId);
        }
    }

    NSManagedObjectContext *context = [[EyeDoorDataModel sharedDataModel] mainContext];
    if (context) {
        ActivityItem *activityItem = [ActivityItem insertInManagedObjectContext:context];

        activityItem.dateReceived = [NSDate date];
        activityItem.message = [userInfo valueForKeyPath:@"aps.alert.body"];
        activityItem.type = [userInfo valueForKeyPath:@"type"];
        //activityItem.imagePath = @"http://i.telegraph.co.uk/multimedia/archive/02351/cross-eyed-cat_2351472k.jpg";

        [context save:nil];

        NSMutableDictionary* notificationUserInfo = [NSMutableDictionary dictionaryWithCapacity:2];
        [notificationUserInfo setObject:activityItem forKey:@"activityItem"];
        [notificationUserInfo setObject:activityItem.type forKey:@"type"];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"newActivityItemAdded" object:activityItem userInfo:notificationUserInfo];
    } else {
        NSLog(@"Failed to store new activity item");
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[deviceToken description] forKey:@"deviceToken"];
    [defaults synchronize];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

@end