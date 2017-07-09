//
//  MainScene.h
//  RobotWarsOSX
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Robot.h"

@class Robot;
@protocol  RobotWallHitDirection;

@protocol GameBoard <NSObject>

@property (atomic, assign) CGFloat currentTimestamp;

// direction should be normalized
- (void)initWithRobotClassOne:(NSString *)botClass1 andRobotClassTwo:(NSString *)botClass2;
- (void)fireBulletFromPosition:(CGPoint)position inDirection:(CGPoint)direction bulletOwner:(id)owner;
- (void)robotDied:(Robot*)robot;
- (RobotWallHitDirection)currentWallHitDirectionForRobot:(Robot*)robot;
- (CGSize)dimensions;

@end

@interface MainScene : SKScene <GameBoard>

@property (atomic, assign) CGFloat currentTimestamp;

@end
