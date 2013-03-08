//
//  SMTimer.h
//  YourRain
//
//  Created by Ivan Trifonov on 24.02.13.
//  Copyright (c) 2013 Ivan Skyer. All rights reserved.
//

#import "SMEventDispatcher.h"

@interface SMTimer : SMEventDispatcher
{
    NSTimer * timer;
}
@property (nonatomic,assign) double rate;
-(void)addListener:(id)target method:(SEL)method;
-(void)removeListener:(id)target method:(SEL)method;

-(void) pause;
-(void) start;
@end
