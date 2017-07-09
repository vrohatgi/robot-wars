//
//  RobotAction.m
//  RobotWar
//
//  Created by Benjamin Encz on 30/05/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "RobotAction.h"

@implementation RobotAction {
    dispatch_semaphore_t _currentActionSemaphore;
    SKAction *_sequence;
}

- (void)run {
    _currentActionSemaphore = dispatch_semaphore_create(0);
    
    SKAction *callback = [SKAction customActionWithDuration:0.f actionBlock:^(SKNode * _Nonnull node, CGFloat elapsedTime) {
        dispatch_semaphore_signal(_currentActionSemaphore);
    }];
    
    _sequence = [SKAction sequence:@[self.action, callback]];
    
    void (^runAction)() = ^void() {
        [self.target runAction:_sequence];
    };
    
    
    if ([NSThread isMainThread])
    {
        runAction();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), runAction);
    }
    
    dispatch_semaphore_wait(_currentActionSemaphore, DISPATCH_TIME_FOREVER);
}

- (void)cancel {
    if (self.canBeCancelled) {
        
        void (^stopAction)() = ^void() {
            [self.target removeAllActions];
        };
        
        if ([NSThread isMainThread])
        {
            stopAction();
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), stopAction);
        }
        
        dispatch_semaphore_signal(_currentActionSemaphore);
    }
}

@end
