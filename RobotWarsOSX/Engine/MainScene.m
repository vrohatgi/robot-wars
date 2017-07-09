//
//  MainScene.m
//  RobotWarsOSX
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Robot.h"
#import "Bullet.h"
#import "GameOverScene.h"
#import "Robot_Framework.h"
#import "GameConstants.h"
#import "Helpers.h"
#import "Configuration.h"
#import "TournamentConfiguration.h"

@implementation MainScene {
    NSTimeInterval timeSinceLastEvent;
    NSTimeInterval lastTimeInterval;
    NSMutableArray *_bullets;
    NSMutableArray *_robots;
    
    SKLabelNode* _robot1Label;
    SKLabelNode* _robot2Label;
    SKLabelNode* _bombCountdownLabel;
    
    CGFloat timeSinceBomb;
}

#pragma mark - Lifecycle / Scene Transitions

- (void)dealloc {
    NSLog(@"Game Over!");
}

- (void)didMoveToView:(SKView *)view {
    [self updateTimeSinceBomb:0.0f];
    
    _bullets = [NSMutableArray array];
    
    _robot1Label = (SKLabelNode *) [self childNodeWithName:@"//robot1Label"];
    _robot1Label.fontName = @"wendy.ttf";
    _robot2Label = (SKLabelNode *) [self childNodeWithName:@"//robot2Label"];
    _robot2Label.fontName = @"wendy.ttf";
    _bombCountdownLabel = (SKLabelNode *) [self childNodeWithName:@"//bombCountdownLabel"];
    _bombCountdownLabel.fontName = @"wendy.ttf";
    
    [self updateScoreLabels];
}

- (Class)swiftClassFromString:(NSString *)className {
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *classStringName = [NSString stringWithFormat:@"_TtC%lu%@%lu%@", (unsigned long)appName.length, appName, (unsigned long)className.length, className];
    return NSClassFromString(classStringName);
}

- (void)initWithRobotClassOne:(NSString *)botClass1 andRobotClassTwo:(NSString *)botClass2  {
    // intantiate two AIs
    Robot *robot1 = (Robot*) [[[self swiftClassFromString:botClass1] alloc] init];
    Robot *robot2 = (Robot*) [[[self swiftClassFromString:botClass2] alloc] init];
    _robots = [NSMutableArray arrayWithArray:@[robot1, robot2]];
    
    // spawn two robots
    robot1.robotNode = [self childNodeWithName:@"robot1"].children[0];
    [robot1 _setRobotColor:[SKColor colorWithRed:251.f/255 green:72.f/255 blue:154.f/255 alpha:1.f]];
    [robot1 _setFieldOfViewColor:[SKColor colorWithRed:251.f/255 green:87.f/255 blue:172.f/255 alpha:0.25f]];
    
    robot1.robotNode.position = CGPointMake(100, arc4random_uniform(608) + 80);
    robot1.gameBoard = self;
    [robot1 _run];
    robot1.robotClass = botClass1;
    
    robot2.robotNode = [self childNodeWithName:@"robot2"].children[0];
    robot2.robotNode.position = CGPointMake(self.size.width - 100, arc4random_uniform(608) + 80);
    robot2.gameBoard = self;
    [robot2 _run];
    robot2.robotNode.zRotation += degToRad(180);
    robot2.robotClass = botClass2;
}

- (void)transitionToGameOverScreen:(NSDictionary *)results {
    GameOverScene *gameOverScene = [GameOverScene nodeWithFileNamed:@"GameOverScene"];
    
    Robot* winner = [results objectForKey:@"Winner"];
    Robot* loser = [results objectForKey:@"Loser"];
    
    gameOverScene.winnerClass = winner.robotClass;
    gameOverScene.winnerName = winner.creator;
    gameOverScene.loserClass = loser.robotClass;
    gameOverScene.loserName = loser.creator;
    
    SKTransition *transition = [SKTransition crossFadeWithDuration:0.3f];
    [self.view presentScene:gameOverScene transition:transition];
}

#pragma mark - Update Loop

- (void)update:(NSTimeInterval)currentTime {
    if (lastTimeInterval == 0) {
        lastTimeInterval = currentTime;
    }
    NSTimeInterval delta = currentTime - lastTimeInterval;
    
    timeSinceLastEvent += delta * GAME_SPEED;
    self.currentTimestamp += delta * GAME_SPEED;
    [self updateTimeSinceBomb:timeSinceBomb + delta * GAME_SPEED];
    
    if (self.currentTimestamp > 240 && TOURNAMENT) {
        for (Robot *robot in _robots) {
            SKEmitterNode *explosion = [SKEmitterNode nodeWithFileNamed:@"BombExplosion"];
            [self addChild:explosion];
            explosion.position = robot.position;
            [robot _gotHit];
        }
    }
    
    for (Robot *robot in _robots) {
        if (!CGRectContainsRect(self.frame, robot.robotNode.frame)) {
            
            /**
             Don't permit robots to leave the arena
             */
            while (CGRectGetMaxX([robot.robotNode frame]) > self.size.width) {
                robot.robotNode.position = CGPointMake(robot.robotNode.position.x-1, robot.robotNode.position.y);
                [self calculateCollisionAngleWithWallNormalVector:CGPointMake(-1, 0) notifyRobot:robot];
            }
            
            while (CGRectGetMaxY([robot.robotNode frame]) > self.size.height) {
                robot.robotNode.position = CGPointMake(robot.robotNode.position.x, robot.robotNode.position.y-1);
                [self calculateCollisionAngleWithWallNormalVector:CGPointMake(0, -1) notifyRobot:robot];
            }
            
            while (CGRectGetMinX([robot.robotNode frame]) < 0) {
                robot.robotNode.position = CGPointMake(robot.robotNode.position.x+1, robot.robotNode.position.y);
                [self calculateCollisionAngleWithWallNormalVector:CGPointMake(+1, 0) notifyRobot:robot];
            }
            
            while (CGRectGetMinY([robot.robotNode frame]) < 0) {
                robot.robotNode.position = CGPointMake(robot.robotNode.position.x, robot.robotNode.position.y+1);
                [self calculateCollisionAngleWithWallNormalVector:CGPointMake(0, +1) notifyRobot:robot];
            }
            
        }
    }
    
    NSMutableArray *cleanupBullets = nil;
    BOOL labelsNeedUpdate = NO;
    
    for (Bullet *bullet in _bullets) {
        
        if (!CGRectContainsRect(self.frame, bullet.frame)) {
            if (!cleanupBullets) {
                cleanupBullets = [NSMutableArray array];
            }
            
            [cleanupBullets addObject:bullet];
            continue;
        }
        
        for (Robot *robot in _robots) {
            if (bullet.bulletOwner == robot) {
                continue;
            } else if (CGRectIntersectsRect(bullet.frame, robot.robotNode.frame)) {
                [robot _gotHit];
                labelsNeedUpdate = YES;
                [bullet.bulletOwner _bulletHitEnemy:bullet];
                
                SKEmitterNode *bulletExplosion = [SKEmitterNode nodeWithFileNamed:@"BulletExplosion"];
                bulletExplosion.position = bullet.position;
                [self addChild:bulletExplosion];
                
                if (!cleanupBullets) {
                    cleanupBullets = [NSMutableArray array];
                }
                
                [cleanupBullets addObject:bullet];
            }
        }
    }
    
    if (self.currentTimestamp > START_BOMBS && timeSinceBomb > BETWEEN_BOMBS) {
        [self dropBomb];
        [self updateTimeSinceBomb:0.0f];
    }
    
    if (labelsNeedUpdate)
        [self updateScoreLabels];
    
    for (Bullet *bullet in cleanupBullets) {
        [self cleanupBullet:bullet];
    }
    
    // Robot Detection
    for (Robot *robot in _robots) {
        for (Robot *otherRobot in _robots) {
            if (otherRobot == robot) {
                continue;
            } else if (distanceBetween(robot.robotNode.position, otherRobot.robotNode.position)  < SCAN_DISTANCE) {
                if (timeSinceLastEvent > 0.5f/GAME_SPEED) {
                    if (fabs([robot angleBetweenGunHeadingDirectionAndWorldPosition:otherRobot.position]) < SCAN_FIELD_OF_VIEW/2) {
                        [robot _scannedRobot:[otherRobot copy] atPosition:otherRobot.robotNode.position];
                        [robot _updateFOVScaned:YES];
                    } else {
                        [robot _updateFOVScaned:NO];
                    }
                    if (fabs([otherRobot angleBetweenGunHeadingDirectionAndWorldPosition:robot.position]) < SCAN_FIELD_OF_VIEW/2) {
                        [otherRobot _scannedRobot:[robot copy] atPosition:robot.robotNode.position];
                        [otherRobot _updateFOVScaned:YES];
                    } else {
                        [otherRobot _updateFOVScaned:NO];
                    }
                    timeSinceLastEvent = 0.f;
                }
            } else {
                [robot _updateFOVScaned:NO];
                [otherRobot _updateFOVScaned:NO];
            }
        }
    }
    
    lastTimeInterval = currentTime;
}

- (void)calculateCollisionAngleWithWallNormalVector:(CGPoint)wallNormalVector notifyRobot:(Robot*)robot {
    if (timeSinceLastEvent > 0.5f/GAME_SPEED) {
        CGFloat collisionAngle;
        RobotWallHitDirection direction;
        calc_collisionAngle_WallHitDirection(wallNormalVector, robot, &collisionAngle, &direction);
        
        [robot _hitWall:direction hitAngle:collisionAngle];
        timeSinceLastEvent = 0.f;
    }
}

- (void)dropBomb {
    CGSize dim = [self dimensions];
    
    int corner = arc4random_uniform(5);
    int angle = arc4random_uniform(90);
    int distance = arc4random_uniform([self dimensions].width/3);
    CGPoint cornerPosition = CGPointZero;
    
    switch (corner) {
        case 0: //bottom-left
            break;
        case 1: //top-left
            cornerPosition = CGPointMake(cornerPosition.x, cornerPosition.y + dim.height);
            angle += 270;
            break;
        case 2: //top-right
            cornerPosition = CGPointMake(cornerPosition.x + dim.width, cornerPosition.y + dim.height);
            angle += 180;
            break;
        case 3: //bottom-right
            cornerPosition = CGPointMake(cornerPosition.x + dim.width, cornerPosition.y);
            angle += 90;
            break;
    }
    
    CGPoint diffFromCorner = pointFromAngle(degToRad(angle), distance);
    CGPoint bombPos = CGPointMake(cornerPosition.x+diffFromCorner.x, cornerPosition.y+diffFromCorner.y);
    
    SKEmitterNode *explosion = [SKEmitterNode nodeWithFileNamed:@"BombExplosion"];
    [self addChild:explosion];
    explosion.position = bombPos;
    
    for (Robot *robot in _robots) {
        if (distanceBetween(robot.position, bombPos) < 135) {
            [robot _bombHit];
        }
    }
    
    [self updateScoreLabels];
}

#pragma mark - GameBoard Protocol

- (CGSize)dimensions {
    return self.size;
}

- (void)fireBulletFromPosition:(CGPoint)position inDirection:(CGPoint)direction bulletOwner:(id)owner {
    Bullet *bullet = [Bullet spriteNodeWithColor:[SKColor colorWithRed:245.f/255 green:245.f/255 blue:245.f/255 alpha:1.f] size:CGSizeMake(10.f, 10.f)];
    SKAction *moveBy = [SKAction moveBy:CGVectorMake(direction.x*20, direction.y*20) duration:0.1f/GAME_SPEED];
    SKAction *repeat = [SKAction repeatActionForever:moveBy];
    
    bullet.bulletOwner = owner;
    [_bullets addObject:bullet];
    [self addChild:bullet];
    bullet.position = position;
    [bullet runAction:repeat];
}

- (void)robotDied:(Robot *)robot {
    dispatch_async(dispatch_get_main_queue(), ^{
        SKEmitterNode *explosion = [SKEmitterNode nodeWithFileNamed:@"RobotExplosion"];
        [self addChild:explosion];
        explosion.position = robot.robotNode.position;
        
        [robot.robotNode removeFromParent];
        [_robots removeObject:robot];
        
        if (_robots.count == 1) {
            NSDictionary* results = @{@"Winner": _robots[0], @"Loser": robot};
            [self performSelector:@selector(transitionToGameOverScreen:) withObject:results afterDelay:3.0f];
        }
    });
}

- (RobotWallHitDirection)currentWallHitDirectionForRobot:(Robot*)robot {
    static NSInteger toleranceMargin = 5;
    
    CGPoint wallNormalVector = CGPointZero;
    
    if (CGRectGetMaxX([robot.robotNode frame]) >= self.size.width - toleranceMargin) {
        wallNormalVector = CGPointMake(-1, 0);
    } else if (CGRectGetMaxY([robot.robotNode frame]) >= self.size.height - toleranceMargin) {
        wallNormalVector = CGPointMake(0, -1);
    } else if (CGRectGetMinX([robot.robotNode frame]) <= toleranceMargin) {
        wallNormalVector = CGPointMake(+1, 0);
    } else if (CGRectGetMinY([robot.robotNode frame]) <= toleranceMargin) {
        wallNormalVector = CGPointMake(0, +1);
    }
    
    if (CGPointEqualToPoint(wallNormalVector, CGPointZero)) {
        return RobotWallHitDirectionNone;
    } else {
        CGFloat collisionAngle;
        RobotWallHitDirection wallHitDirection;
        calc_collisionAngle_WallHitDirection(wallNormalVector, robot, &collisionAngle, &wallHitDirection);
        return wallHitDirection;
    }
}

#pragma mark - Util Methods/Functions

- (void)updateScoreLabels {
    Robot* robot1 = nil;
    Robot* robot2 = nil;
    
    if (_robots.count > 0) robot1 = (Robot*) _robots[0];
    if (_robots.count > 1) robot2 = (Robot*) _robots[1];
    
    if (robot1)
        _robot1Label.text = [NSString stringWithFormat:@"%@: %ld", robot1.robotClass, (long)[robot1 hitPoints]];
    else
        _robot1Label.text = [NSString stringWithFormat:@"DEAD"];
    
    if (robot2)
        _robot2Label.text = [NSString stringWithFormat:@"%@: %ld", robot2.robotClass, (long)[robot2 hitPoints]];
    else
        _robot2Label.text = [NSString stringWithFormat:@"DEAD"];
}

- (void)updateTimeSinceBomb:(CGFloat)pTimeSinceBomb {
    timeSinceBomb = pTimeSinceBomb;
    
    float timeUntilBomb = 0.0f;
    
    if (self.currentTimestamp > START_BOMBS)
    {
        timeUntilBomb = BETWEEN_BOMBS - timeSinceBomb;
    }
    else
    {
        timeUntilBomb = START_BOMBS - timeSinceBomb;
    }
    
    if (timeUntilBomb <= 1.0f)
    {
        _bombCountdownLabel.text = @"Warning";
        _bombCountdownLabel.color = [SKColor colorWithRed:1.f green:0.f blue:1.f alpha:1.f];
    }
    else
    {
        _bombCountdownLabel.text = [NSString stringWithFormat:@"%.0f", timeUntilBomb];
        _bombCountdownLabel.color = [SKColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f];
    }
}

- (void)cleanupBullet:(Bullet *)bullet {
    [bullet removeFromParent];
    [_bullets removeObject:bullet];
}

void calc_collisionAngle_WallHitDirection(CGPoint wallNormalVector, Robot *robot, CGFloat *collisionAngle_p, RobotWallHitDirection *direction_p) {
    // Calculate Collision Angle
    *collisionAngle_p = angleSigned([robot headingDirection], wallNormalVector);
    *collisionAngle_p = roundf(radToDeg(*collisionAngle_p));
    while (*collisionAngle_p < -180) { *collisionAngle_p += 360; }
    while (*collisionAngle_p > 180) { *collisionAngle_p -= 360; }
    *direction_p = radAngleToRobotWallHitDirection(*collisionAngle_p);
}

@end
