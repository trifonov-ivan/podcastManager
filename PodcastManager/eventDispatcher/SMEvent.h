//
//  SMEvent.h
//  StateMachine
//
//  Created by Ivan Skyer on 2/18/13.
//  Copyright (c) 2013 Ivan Skyer. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface SMEvent : NSObject
@property (nonatomic, assign) int key;
@property (nonatomic, strong) id data;
+(id) eventWithKey:(int)key andData:(id)data;
@end
