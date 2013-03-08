//
//  SMTimer.m
//  YourRain
//
//  Created by Ivan Trifonov on 24.02.13.
//  Copyright (c) 2013 Ivan Skyer. All rights reserved.
//

#import "SMTimer.h"
#define SM_TIMER_EVENT 501202
@interface SMTimer()
{
    BOOL isActive;
}
@end

@implementation SMTimer
- (id)init
{
    self = [super init];
    if (self) {
        _rate = 1/24.0;
    }
    return self;
}
-(void)addListener:(id)target method:(SEL)method
{
    [self addListener:SM_TIMER_EVENT target:target method:method];
}
-(void)removeListener:(id)target method:(SEL)method
{
    [self removeListener:SM_TIMER_EVENT target:target method:method];
}

-(void)addListener:(int)eventKey target:(id)target method:(SEL)method
{
    if (!listeners.allValues.count)
    {
        [self startTicking];
    }
    [super addListener:eventKey target:target method:method];
}
-(void)removeListener:(int)eventKey target:(id)target method:(SEL)method
{
    [super removeListener:eventKey target:target method:method];
    if (!listeners.allValues.count)
    {
        [self endTicking];
    }

}

-(void) startTicking
{
    timer = [NSTimer timerWithTimeInterval:_rate target:self selector:@selector(tick) userInfo:nil repeats:YES];
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:timer forMode: NSDefaultRunLoopMode];
    isActive = YES;
}

-(void) endTicking
{
    [timer invalidate];
    isActive = NO;

}

-(void) tick
{
    if (isActive)
    {
        [self dispatchEvent:[SMEvent eventWithKey:SM_TIMER_EVENT andData:nil]];
    }
}

-(void) pause
{
    isActive = NO;
}

-(void) start
{
    isActive = YES;
}
@end
