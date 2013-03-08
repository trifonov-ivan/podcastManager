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
        NSString *pListPath = [[NSBundle mainBundle] pathForResource:@"podcasts" ofType:@"plist"];
        podcastsDict = [NSMutableDictionary dictionaryWithContentsOfFile:pListPath];
    
    }
    return self;
}

- (void) storeChanges
{
    NSLog(@"%@",podcastsDict);
    NSString *pListPath = [[NSBundle mainBundle] pathForResource:@"podcasts" ofType:@"plist"];
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:podcastsDict format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
//    [data writeToFile:pListPath atomically:YES];
}

- (void) testPodcastForAvailability:(NSString*) podcast target:(id)target method:(SEL)method
{
    if (!podcastsDict[podcast])
        return;
}
- (double) podcastLocalLength:(NSString*) podcast
{
    if (!podcastsDict[podcast])
        return 0;
}

- (NSURL*) getRandomSoundForPodcast:(NSString*) podcast
{
    NSDictionary *dict = podcastsDict[podcast][@"local"];
    NSString *name = dict[@"name"];
    int limit = [dict[@"limit"] intValue];
    if (!name || !limit) return nil;

    NSString *cachesFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *folder = [cachesFolder stringByAppendingPathComponent:@"Podcasts"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:folder isDirectory:YES])
    {
        [fileManager createDirectoryAtPath:folder withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSString *filePath = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d",name,arc4random()%limit]];
    if ([fileManager fileExistsAtPath:filePath isDirectory:nil])
    {
        return [NSURL fileURLWithPath:filePath];
    }
    return nil;
}

- (NSString*) getFilePathForNextFileForPodcast:(NSString*)podcast
{
    NSDictionary *dict = podcastsDict[podcast][@"local"];
    NSString *name = dict[@"name"];
    int limit = [dict[@"limit"] intValue];
    if (!name || !limit) return nil;
    
    NSString *cachesFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *folder = [cachesFolder stringByAppendingPathComponent:@"Podcasts"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:folder isDirectory:YES])
    {
        [fileManager createDirectoryAtPath:folder withIntermediateDirectories:NO attributes:nil error:nil];
    }

    int i=0;
    while (i<limit+1)
    {
        NSString *filePath = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d",name,i]];
        if (![fileManager fileExistsAtPath:filePath isDirectory:nil])
        {
            if (i == limit)
            {
                podcastsDict[podcast][@"local"][@"limit"]=@(limit+1);
            }
            return filePath;
        }
        i++;
    }
    
    return nil;
}

- (NSURL *) getRemotePodcast:(NSString*) podcast
{
    NSString *link = podcastsDict[podcast][@"remote"];
    if (link)
    {
        return [NSURL URLWithString:link];
    }
    return nil;
}

- (BOOL) startPlayingPodcast:(NSString*) podcast local:(BOOL)locally downloading:(BOOL)downloading
{
    if (!podcastsDict[podcast])
        return NO;

    if (streamer)
    {
        [streamer stop];
        streamer = nil;
    }
    if (filePlayer)
    {
        [filePlayer stop];
        filePlayer = nil;
    }
    local = locally;
    down = downloading;
    NSURL *playURL = nil;

    if (local)
    {
        playURL = [self getRandomSoundForPodcast:podcast];
    }
    else
    {
        playURL = [self getRemotePodcast:podcast];
    }
    
    if (!playURL) return NO;
    
    if (!local)
    {
        streamer = [[AudioStreamer alloc] initWithURL:playURL];
        if (downloading)
        {
            [streamer setFileToWrite:[self getFilePathForNextFileForPodcast:podcast]];
        }
        [streamer start];
        return YES;
    }
    else
    {
        filePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:playURL error:nil];
        [filePlayer play];
        return YES;
    }
    
    return NO;
}

- (void) pause
{
    if (streamer)
        [streamer pause];
    if (filePlayer)
        [filePlayer pause];
}

- (void) play
{
    if (streamer)
        [streamer start];
    if (filePlayer)
        [filePlayer play];
}

- (void) endCurrentPodcast
{
    [self storeChanges];
    if (streamer)
    {
        if (down)
            [streamer endRecord];
        [streamer stop];
        streamer = nil;
    }
    if (filePlayer)
    {
        [filePlayer stop];
        filePlayer = nil;
    }
}



-(void) playPodcast:(NSString*)path
{
    NSString *cachesFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *file = [cachesFolder stringByAppendingPathComponent:@"testfile.mp3"];
    
    NSURL *audioUrl= nil;//[NSURL URLWithString:path];
    if (audioUrl)
    {
    streamer = [[AudioStreamer alloc] initWithURL:audioUrl];

    [streamer setFileToWrite:file];
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
