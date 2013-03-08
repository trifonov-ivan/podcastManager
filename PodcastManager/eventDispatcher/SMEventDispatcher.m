//
//  SMEventDispatcher.m
//  StateMachine
//
//  Created by Ivan Skyer on 2/18/13.
//  Copyright (c) 2013 Ivan Skyer. All rights reserved.
//

#import "SMEventDispatcher.h"

@implementation SMEventDispatcher

- (id)init
{
    self = [super init];
    if (self) {
        listeners = [[NSMutableDictionary alloc] init];
    }
    return self;
}
-(void) addListener:(int) eventKey target: (id) target method: (SEL) method
{
	NSNumber *key = [NSNumber numberWithInt:eventKey];
	NSMutableArray *arr = listeners[key];
	if (!arr)
		arr = [NSMutableArray new];    
	
    SMEventNotifier *en = [[SMEventNotifier alloc] init];
	en.object = target;
	en.method = method;
	
	[arr addObject:en];
    listeners[key] = arr;    
}

-(void) removeListener:(int) eventKey target: (id) target method: (SEL) method
{
	NSNumber *key = [NSNumber numberWithInt:eventKey];
	NSMutableArray *arr = listeners[key];
	if (!arr)
		return;
	id toDelete = nil;
	for (SMEventNotifier *a in arr)
	{
		if ((a.object == target) && (a.method == method))
		{
			toDelete = a;
		}
	}
	if (toDelete)
		[arr removeObject:toDelete];
	if (!arr.count)
        [listeners removeObjectForKey:key];
}

-(SMEventNotifier*)hasListener:(id) object_ forEvent:(int)event
{
    return [self hasListener:object_ forEvent:event offset:0];
}

-(SMEventNotifier*)hasListener:(id) object_ forEvent:(int)event offset:(int) _offset
{
    NSArray *arr = listeners[ [NSNumber numberWithInt:event] ];
    int k = 0;
    for (SMEventNotifier *listener in arr)
    {
        if (listener.object == object_)
        {
            if (k+1 > _offset)
            {
                return listener;
            }
            else
            {
                k++;
            }
        }
    }
    return nil;
}


//Методы для обращения
-(BOOL) dispatchEvent:(SMEvent*) event
{
	NSArray *arr = [listeners[ [NSNumber numberWithInt:event.key] ] arrayByAddingObjectsFromArray:listeners[ @0 ]];
	for (SMEventNotifier *a in arr)
	{
		[a.object performSelector:a.method withObject:event];
	}
    return (arr.count > 0);
}

@end
