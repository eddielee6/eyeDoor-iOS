//
//  eyeDoorAppDelegate.m
//  eyeDoor
//
//  Created by Eddie Lee on 22/02/2013.
//  Copyright (c) 2013 Eddie Lee. All rights reserved.
//
//  Based on code from Matthew Eagar
//  Copyright 2011 ThinkFlood Inc. All rights reserved.

@interface MotionJpegImageView : UIImageView

@property (nonatomic, readwrite, copy) NSURL *url;
@property (nonatomic, readonly) BOOL isPlaying;

- (void)play;
- (void)pause;
- (void)clear;
- (void)stop;

@end