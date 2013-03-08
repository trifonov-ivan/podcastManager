//
//  PodcastEngine.m
//  YourRain
//
//  Created by Ivan Trifonov on 03.03.13.
//  Copyright (c) 2013 Ivan Skyer. All rights reserved.
//

#import "PodcastEngine.h"
#import "SMTimer.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
static PodcastEngine * sharedEngine = nil;
@implementation PodcastEngine

+ (PodcastEngine *) sharedEngine
{
	@synchronized(self)     {
		if (!sharedEngine)
			sharedEngine = [[PodcastEngine alloc] init];
	}
	return sharedEngine;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self playPodcast:@"http://188.127.226.185/;stream.nsv?45"];
        timer = [[SMTimer alloc] init];
        [timer addListener:self method:@selector(tick:)];
    }
    return self;
}

-(void) tick:(SMEvent*) event
{
}

-(void) playPodcast:(NSString*)path
{
    NSString *cachesFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *file = [cachesFolder stringByAppendingPathComponent:@"testfile.mp3"];
    
    NSURL *audioUrl= nil;//[NSURL URLWithString:path];
    if (audioUrl)
    {
    streamer = [[AudioStreamer alloc] initWithURL:audioUrl];

//    [streamer setFileToWrite:file];
    [streamer start];
        
    }
    else
    {
        audioUrl = [NSURL fileURLWithPath:file];
        filePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:nil];
        [filePlayer setNumberOfLoops:-1];
        [filePlayer play];
    }
    
}

@end
