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
#import "PodcastTester.h"
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

-(void) dealloc
{
    NSLog(@"what the duck?!");
}
- (id)init
{
    self = [super init];
    if (self) {
        NSString *pListPath = [[NSBundle mainBundle] pathForResource:@"podcasts" ofType:@"plist"];
        podcastsDict = [NSMutableDictionary dictionaryWithContentsOfFile:pListPath];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willDie:) name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];
    }
    return self;
}

-(void) willDie:(NSNotification*) ntf
{
    [self endCurrentPodcast];
}

- (void) storeChanges
{
    NSString *pListPath = [[NSBundle mainBundle] pathForResource:@"podcasts" ofType:@"plist"];
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:podcastsDict format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
    [data writeToFile:pListPath atomically:YES];
}

- (void) testPodcastForAvailability:(NSString*) podcast target:(id)target method:(SEL)method
{
    NSURL *url = [NSURL URLWithString:podcastsDict[podcast][@"remote"]];
    NSError *err = nil;
    
    MPMoviePlayerController * pl = [[MPMoviePlayerController alloc] initWithContentURL:url];
    if (!testers)
        testers = [NSMutableArray new];

    NSDictionary * params = @{
                              @"target":target,
                              @"method":[NSValue valueWithPointer:method],
                              @"player":pl? pl : [NSNull null],
                              @"podcast":podcast? podcast : [NSNull null],
                              @"holder":testers
                              };
    
    PodcastTester *tester = [[PodcastTester alloc] initWithParams:params];

    [testers addObject:tester];
}

- (NSArray*) availablePodcasts
{
    return [podcastsDict allKeys];
}

- (NSMutableDictionary*) getInitialPodcastInfo:(NSString*) podcast
{
    NSDictionary *dict = podcastsDict[podcast];
    return [NSMutableDictionary dictionaryWithDictionary:@{
             @"name":podcast,//dict[@"local"][@"name"],
             @"availability":@(-1),
             @"localtime":dict[@"local"][@"duration"]
             }];
}

- (double) durationOfFileByPath:(NSString*) path
{
    NSTimeInterval length = 0.0;
    NSURL *audioURL = [NSURL fileURLWithPath: path];
    
    OSStatus result = noErr;
    
    AudioFileID audioFile = NULL;
    result = AudioFileOpenURL ((__bridge CFURLRef)audioURL,
                               kAudioFileReadPermission,
                               0, // hint
                               &audioFile);
    if (result != noErr) goto bailout;
    
    //Get file length
    NSTimeInterval seconds;
    UInt32 propertySize = sizeof (seconds);
    result = AudioFileGetProperty (audioFile,
                                   kAudioFilePropertyEstimatedDuration,
                                   &propertySize,
                                   &seconds);
    if (result != noErr) goto bailout;
    
    length = seconds;
    
bailout:
    if (audioFile) AudioFileClose (audioFile);
    return length;
}

- (double) podcastLocalLength:(NSString*) podcast
{
    if (!podcastsDict[podcast])
        return 0;
}

-(NSString*) getSoundForPodcast:(NSString*)podcast withNumber:(int)number
{
    NSDictionary *dict = podcastsDict[podcast][@"local"];
    NSString *name = dict[@"name"];
    int limit = [dict[@"limit"] intValue];
    if (!name || !limit) return nil;

    NSString *cachesFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *folder = [cachesFolder stringByAppendingPathComponent:@"Podcasts"];
    NSString *filePath = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d",name,number]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath isDirectory:nil])
    {
        return filePath;
    }
    return nil;
}

- (NSURL*) getRandomSoundForPodcast:(NSString*) podcast
{
    NSDictionary *dict = podcastsDict[podcast][@"local"];
    NSString *name = dict[@"name"];
    int limit = [dict[@"limit"] intValue];
    if (!name || !limit) return nil;

    return [NSURL URLWithString:[self getSoundForPodcast:podcast withNumber:arc4random()%limit]];
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

    [self endCurrentPodcast];
    
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
    
    currentPodcast = podcast;
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
    if (streamer)
    {
        if (down)
        {
            podcastsDict[currentPodcast][@"local"][@"duration"] = @([podcastsDict[currentPodcast][@"local"][@"duration"] doubleValue] + [streamer recordedDuration]);
            [streamer endRecord];
        }
        [streamer stop];
        streamer = nil;
    }
    if (filePlayer)
    {
        [filePlayer stop];
        filePlayer = nil;
    }
    currentPodcast = nil;
    [self storeChanges];
}

- (double) durationOfCurrentPodcast
{
    return [podcastsDict[currentPodcast][@"local"][@"duration"] doubleValue] + [streamer recordedDuration];
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
