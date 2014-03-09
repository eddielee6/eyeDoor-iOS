//
//  settingsHelper.h
//  eyeDoor
//
//  Created by Eddie Lee on 10/04/2013.
//  Copyright (c) 2013 Eddie Lee. All rights reserved.
//

@interface SettingsHelper : NSObject

- (NSString *)getURL;
- (NSString *)getDeviceToken;
- (NSNumber *)getStreamingPortNumber;
- (NSNumber *)getControlPortNumber;

- (void)setURL:(NSString *)url;
- (void)setStreamingPortNumber:(NSNumber *)portNumber;
- (void)setControlPortNumber:(NSNumber *)portNumber;

@end
