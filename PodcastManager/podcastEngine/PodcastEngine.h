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
}

+ (PodcastEngine *) sharedEngine;

- (void) testPodcastForAvailability:(NSString*) podcastURL;

@end
