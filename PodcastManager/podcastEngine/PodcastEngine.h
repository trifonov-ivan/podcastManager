//
//  PodcastEngine.h
//  YourRain
//
//  Created by Ivan Trifonov on 03.03.13.
//  Copyright (c) 2013 Ivan Skyer. All rights reserved.
//

#import "SMEventDispatcher.h"
#import <Foundation/Foundation.h>
#import "SMTimer.h"
#import "AudioStreamer.h"
@class SMTimer;
@class AVAudioPlayer;
@interface PodcastEngine : SMEventDispatcher
{
    SMTimer * timer;
    AudioStreamer *streamer;
    AVAudioPlayer *filePlayer;
    NSDictionary *podcastsDict;
    BOOL local,down;
}

+ (PodcastEngine *) sharedEngine;

- (void) testPodcastForAvailability:(NSString*) podcast target:(id)target method:(SEL)method;
- (double) podcastLocalLength:(NSString*) podcast;
- (BOOL) startPlayingPodcast:(NSString*) podcast local:(BOOL)locally downloading:(BOOL)downloading;
- (void) pause;
- (void) play;
- (void) endCurrentPodcast;
@end
