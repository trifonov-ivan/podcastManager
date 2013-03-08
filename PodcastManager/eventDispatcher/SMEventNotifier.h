//
//  SMEventNotifier.h
//  StateMachine
//
//  Created by Ivan Skyer on 2/18/13.
//  Copyright (c) 2013 Ivan Skyer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMEventNotifier : NSObject

@property (nonatomic, strong) id object;
@property (nonatomic, assign) SEL method;

@end
