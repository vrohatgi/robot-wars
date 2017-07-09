//
//  RobotAction.h
//  RobotWar
//
//  Created by Benjamin Encz on 30/05/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface RobotAction : NSObject

@property (weak, nonatomic) SKNode *target;
@property (strong, nonatomic) SKAction *action;
@property (assign, nonatomic) BOOL canBeCancelled;

- (void)run;
- (void)cancel;

@end
