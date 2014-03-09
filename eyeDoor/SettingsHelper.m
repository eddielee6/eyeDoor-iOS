//
//  settingsHelper.m
//  eyeDoor
//
//  Created by Eddie Lee on 10/04/2013.
//  Copyright (c) 2013 Eddie Lee. All rights reserved.
//

#import "SettingsHelper.h"

@interface SettingsHelper ()

@property (strong, nonatomic) NSUserDefaults *userDefaults;

@end

@implementation SettingsHelper

-(id)init
{
    self = [super init];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    return self;
}

- (NSString *)getURL
{
    if([self.userDefaults objectForKey:@"feedUrl"]) {
        return [self.userDefaults objectForKey:@"feedUrl"];
    } else {
        return @"http://192.168.0.14";
    }
}

- (NSString *)getDeviceToken
{
    if([self.userDefaults objectForKey:@"deviceToken"]) {
        return [self.userDefaults objectForKey:@"deviceToken"];
    } else {
        return @"No device token";
    }
}

- (NSNumber *)getStreamingPortNumber
{
    if([self.userDefaults objectForKey:@"streamingPort"]) {
        return [self.userDefaults objectForKey:@"streamingPort"];
    } else {
        return @8081;
    }
}

- (NSNumber *)getControlPortNumber
{
    if([self.userDefaults objectForKey:@"controlPort"]) {
        return [self.userDefaults objectForKey:@"controlPort"];
    } else {
        return @8080;
    }
}

- (void)setURL:(NSString *)url
{
    [self.userDefaults setObject:url forKey:@"feedUrl"];
    [self.userDefaults synchronize];
}

- (void)setStreamingPortNumber:(NSNumber *)portNumber
{
    [self.userDefaults setObject:portNumber forKey:@"streamingPort"];
    [self.userDefaults synchronize];
}


- (void)setControlPortNumber:(NSNumber *)portNumber
{
    [self.userDefaults setObject:portNumber forKey:@"controlPort"];
    [self.userDefaults synchronize];
}


@end
