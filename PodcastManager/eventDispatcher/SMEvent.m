//
//  SMEvent.m
//  StateMachine
//
//  Created by Ivan Skyer on 2/18/13.
//  Copyright (c) 2013 Ivan Skyer. All rights reserved.
//

#import "SMEvent.h"

@implementation SMEvent
+(id) eventWithKey:(int)key andData:(id)data
{
    SMEvent *ev=[[SMEvent alloc] init];
    ev.key = key;
    ev.data = data;
    return ev;
}
@end
