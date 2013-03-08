//
//  SMEventDispatcher.h
//  StateMachine
//
//  Created by Ivan Skyer on 2/18/13.
//  Copyright (c) 2013 Ivan Skyer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMEvent.h"
#import "SMEventNotifier.h"

@interface SMEventDispatcher : NSObject
{
	NSMutableDictionary * listeners;
}

//Методы для обращения извне
//If event key is equal to 0 then every message sends to this listener
-(void) addListener:(int) eventKey target: (id) target method: (SEL) method;
-(void) removeListener:(int) eventKey target: (id) target method: (SEL) method;
-(SMEventNotifier*)hasListener:(id) object_ forEvent:(int)event;
-(SMEventNotifier*)hasListener:(id) object_ forEvent:(int)event offset:(int) _offset;

//Методы для обращения
-(BOOL) dispatchEvent:(SMEvent*) event;

@end
