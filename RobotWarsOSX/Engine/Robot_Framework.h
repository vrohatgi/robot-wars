//
//  Robot_Framework.h
//  RobotWar
//
//  Created by Benjamin Encz on 03/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Robot.h"
#import "MainScene.h"

@interface Robot ()

@property (weak, nonatomic) id<GameBoard> gameBoard;
@property (weak, nonatomic) SKNode *robotNode;

- (void)_scannedRobot:(Robot*)robot atPosition:(CGPoint)position;
- (void)_hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle;
- (void)_gotHit;
- (void)_bombHit;
- (void)_run;
- (void)_bulletHitEnemy:(Bullet*)bullet;
- (void)_setRobotColor:(SKColor*)color;
- (void)_setFieldOfViewColor:(SKColor*)color;
- (void)_updateFOVScaned:(BOOL)scanned;

@end
