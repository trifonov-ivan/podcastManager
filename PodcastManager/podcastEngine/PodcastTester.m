//
//  PodcastTester.m
//  PodcastManager
//
//  Created by Ivan Trifonov on 08.03.13.
//  Copyright (c) 2013 Ivan Trifonov. All rights reserved.
//

#import "PodcastTester.h"
#import <MediaPlayer/MediaPlayer.h>

@interface PodcastTester ()

@property (nonatomic,strong) NSDictionary* innerData;
@property (nonatomic,strong) MPMoviePlayerController* player;

@end


@implementation PodcastTester

- (id)initWithParams:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        _innerData = data;
        MPMoviePlayerController *pl = data[@"player"];
        _player = pl;
        id target = data[@"target"];
        SEL method = [data[@"method"] pointerValue];
        NSString *podcast = data[@"podcast"];
        if ([pl isKindOfClass:[NSNull class]])
        {
            [target performSelector:method withObject:@{@"name":podcast,@"availability":@0}];
        }
        else
        {
            pl.shouldAutoplay = NO;
            [pl prepareToPlay];
            NSNotificationCenter *ntf = [NSNotificationCenter defaultCenter];
            [ntf addObserver:self selector:@selector(stateChanged:) name:MPMoviePlayerLoadStateDidChangeNotification object:pl];
            [self performSelector:@selector(podcastResume:) withObject:_innerData afterDelay:5];
        }
    }
    return self;
}

-(void) stateChanged:(NSNotification*)ntf
{
    if (ntf.object != _player) return;
        if ([(MPMoviePlayerController*)ntf.object loadState])
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(podcastResume:) object:_innerData];
            [self podcastResume:_innerData];
        }
}

- (void) podcastResume:(NSDictionary*) data
{
    MPMoviePlayerController *pl = data[@"player"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:pl];
    id target = data[@"target"];
    SEL method = [data[@"method"] pointerValue];
    NSString *podcast = data[@"podcast"];
    if (pl.loadState)
    {
        [target performSelector:method withObject:@{@"name":podcast,@"availability":@1}];
    }
    else
    {
        [target performSelector:method withObject:@{@"name":podcast,@"availability":@0}];
    }
    [data[@"holder"] removeObject:self];
}


-(void) testDict:(NSDictionary*)dict
{
    
}
@end
