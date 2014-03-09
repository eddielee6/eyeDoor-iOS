//
//  eyeDoorAppDelegate.m
//  eyeDoor
//
//  Created by Eddie Lee on 22/02/2013.
//  Copyright (c) 2013 Eddie Lee. All rights reserved.
//
//  Based on code from Matthew Eagar
//  Copyright 2011 ThinkFlood Inc. All rights reserved.

#import "MotionJpegImageView.h"

#pragma mark - Constants

#define END_MARKER_BYTES { 0xFF, 0xD9 }

static NSData *_endMarkerData = nil;

#pragma mark - Private Method Declarations

@interface MotionJpegImageView () {
    NSURLConnection *_connection;
    NSMutableData *_receivedData;
}

- (void)cleanupConnection;

@end

#pragma mark - Implementation

@implementation MotionJpegImageView

@dynamic isPlaying;

- (BOOL)isPlaying
{
    return (self.image != nil && _connection != nil);
    
}

#pragma mark - Initializers

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        self.url = nil;
        _receivedData = nil;

        if (_endMarkerData == nil) {
            uint8_t endMarker[2] = END_MARKER_BYTES;
            _endMarkerData = [[NSData alloc] initWithBytes:endMarker length:2];
        }

        self.contentMode = UIViewContentModeScaleAspectFill;
    }

    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];

    if (_endMarkerData == nil) {
        uint8_t endMarker[2] = END_MARKER_BYTES;
        _endMarkerData = [[NSData alloc] initWithBytes:endMarker length:2];
    }

    self.contentMode = UIViewContentModeScaleAspectFill;
}

#pragma mark - Overrides

- (void)dealloc
{
    if (_connection) {
        [_connection cancel];
        [self cleanupConnection];
    }
}

#pragma mark - Public Methods

- (void)play
{
    if (!_connection && self.url) {
        _connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:_url]
                                                      delegate:self];
    }
}

- (void)pause
{
    if (_connection) {
        [_connection cancel];
        [self cleanupConnection];
    }
}

- (void)clear
{
    self.image = nil;
}

- (void)stop
{
    [self pause];
    [self clear];
}

#pragma mark - Private Methods

- (void)cleanupConnection
{
    if (_connection) {
        _connection = nil;
    }

    if (_receivedData) {
        _receivedData = nil;
    }
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _receivedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receivedData appendData:data];
    NSRange endRange = [_receivedData rangeOfData:_endMarkerData
                                          options:0
                                            range:NSMakeRange(0, _receivedData.length)];

    long long endLocation = endRange.location + endRange.length;
    if (_receivedData.length >= endLocation) {
        NSData *imageData = [_receivedData subdataWithRange:NSMakeRange(0, endLocation)];
        UIImage *receivedImage = [UIImage imageWithData:imageData];
        if (receivedImage) {
            self.image = receivedImage;
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self cleanupConnection];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self cleanupConnection];
}

@end
