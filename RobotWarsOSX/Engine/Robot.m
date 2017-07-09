//
//  Robot.m
//  RobotWar
//
//  Created by Benjamin Encz on 29/05/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Robot.h"
#import "RobotAction.h"
#import "Robot_Framework.h"
#import "GameConstants.h"
#import "MainScene.h"
#import "Helpers.h"

@interface Robot ()

@property (nonatomic, assign) NSInteger health;

@end

@implementation Robot {
    SKSpriteNode *_barrel;
    SKSpriteNode *_body;
    SKSpriteNode *_healthBar;
    SKSpriteNode *_fieldOfViewNode;
    
    dispatch_queue_t _backgroundQueue;
    dispatch_queue_t _mainQueue;
    
    dispatch_group_t mainQueueGroup;
    
    RobotAction *_currentRobotAction;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.health = ROBOT_INITIAL_LIFES;
        
        _backgroundQueue = dispatch_queue_create("backgroundQueue", DISPATCH_QUEUE_SERIAL);
        _mainQueue = dispatch_queue_create("mainQueue", DISPATCH_QUEUE_SERIAL);
        mainQueueGroup = dispatch_group_create();
    }
    
    return self;
}

- (void)setRobotNode:(SKNode *)robotNode {
    _body = (SKSpriteNode *) [robotNode childNodeWithName:@"body"];
    _barrel = (SKSpriteNode *) [_body childNodeWithName:@"barrel"];
    _healthBar = (SKSpriteNode *) [_body childNodeWithName:@"healthBar"];
    _fieldOfViewNode = (SKSpriteNode *) [_barrel childNodeWithName:@"fieldOfView"];
    _robotNode = _body;
}

- (void)_setRobotColor:(SKColor*)color {
    [_body setColor:color];
}

- (void)_setFieldOfViewColor:(SKColor*)color {
    [_fieldOfViewNode setColor:color];
}

- (void)_updateFOVScaned:(BOOL)scanned {
    if (scanned) {
        _fieldOfViewNode.alpha = 0.75f;
    } else {
        _fieldOfViewNode.alpha = 0.35f;
    }
}

- (void)runRobotAction:(SKAction *)action target:(SKNode*)target canBeCancelled:(BOOL)canBeCancelled {
    // ensure that background queue cannot spawn any actions will main queue is operating
    [self waitForMainQueue];
    
    RobotAction *robotAction = [[RobotAction alloc] init];
    robotAction.target = target;
    robotAction.action = action;
    robotAction.canBeCancelled = canBeCancelled;
    _currentRobotAction = robotAction;
    
    [robotAction run];
    
    _currentRobotAction = nil;
}

- (void)turnGunLeft:(NSInteger)degree {
    if (degree <= 0) { return; }
    [self waitForMainQueue];
    
    CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND / GAME_SPEED;
    SKAction *rotateBy = [SKAction rotateByAngle:degToRad(degree) duration:duration];
    
    [self runRobotAction:rotateBy target:_barrel canBeCancelled:TRUE];
}

- (void)turnGunRight:(NSInteger)degree {
    if (degree <= 0) { return; }
    [self waitForMainQueue];
    
    CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND / GAME_SPEED;
    SKAction *rotateBy = [SKAction rotateByAngle:-degToRad(degree) duration:duration];
    
    [self runRobotAction:rotateBy target:_barrel canBeCancelled:TRUE];
}

- (void)turnRobotLeft:(NSInteger)degree {
    if (degree <= 0) { return; }
    [self waitForMainQueue];
    
    CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND / GAME_SPEED;
    SKAction *rotateBy = [SKAction rotateByAngle:degToRad(degree) duration:duration];
    
    [self runRobotAction:rotateBy target:_body canBeCancelled:TRUE];
}


- (void)turnRobotRight:(NSInteger)degree {
    if (degree <= 0) { return; }
    [self waitForMainQueue];
    
    CGFloat duration = degree / ROBOT_DEGREES_PER_SECOND / GAME_SPEED;
    SKAction *rotateBy = [SKAction rotateByAngle:-degToRad(degree) duration:duration];
    
    [self runRobotAction:rotateBy target:_body canBeCancelled:TRUE];
}

- (void)moveAhead:(NSInteger)distance {
    if (distance <= 0) { return; }
    [self waitForMainQueue];
    
    CGFloat duration = distance / ROBOT_DISTANCE_PER_SECOND / GAME_SPEED;
    CGPoint direction = [self directionFromRotation:_body.zRotation];
    CGVector targetPoint = CGVectorMake(direction.x*distance, direction.y*distance);
    SKAction *actionMoveBy = [SKAction moveBy:targetPoint duration:duration];
    
    [self runRobotAction:actionMoveBy target:_body canBeCancelled:TRUE];
}


- (void)moveBack:(NSInteger)distance {
    if (distance <= 0) { return; }
    [self waitForMainQueue];
    
    CGFloat duration = distance / ROBOT_DISTANCE_PER_SECOND / GAME_SPEED;
    CGPoint direction = [self directionFromRotation:_body.zRotation];
    CGVector targetPoint = CGVectorMake(direction.x*-distance, direction.y*-distance);
    SKAction *actionMoveBy = [SKAction moveBy:targetPoint duration:duration];
    
    [self runRobotAction:actionMoveBy target:_body canBeCancelled:TRUE];
}

- (void)waitForMainQueue {
    // ensure that background queue cannot spawn any actions while main queue is operating
    if (dispatch_get_current_queue() == _backgroundQueue) {
        if (mainQueueGroup != NULL) {
            dispatch_group_wait(mainQueueGroup, DISPATCH_TIME_FOREVER);
        }
    }
}

- (void)shoot {
    CGPoint direction = [self gunHeadingDirection];
    
    void (^fireAction)() = ^void() {
        [self.gameBoard fireBulletFromPosition:_body.position inDirection:direction bulletOwner:self];
    };
    
    
    if ([NSThread isMainThread])
    {
        fireAction();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), fireAction);
    }
    
    SKAction *delay = [SKAction waitForDuration:1.f/GAME_SPEED];
    [self runRobotAction:delay target:_body canBeCancelled:FALSE];
}


- (void)_run {
    dispatch_async(_backgroundQueue, ^{
        [self run];
    });
}

#pragma mark - Info

- (NSInteger)hitPoints {
    return self.health;
}

- (CGPoint)headingDirection {
    return [self directionFromRotation:_body.zRotation];
}

- (CGFloat)angleBetweenHeadingDirectionAndWorldPosition:(CGPoint)position {
    // vector between robot position and target position
    CGPoint directionVector = CGPointMake(position.x - _body.position.x, position.y - _body.position.y);
    CGPoint currentHeading = [self headingDirection];
    
    return roundf(radToDeg(angleSigned(directionVector, currentHeading)));
}

- (CGPoint)gunHeadingDirection {
    CGFloat combinedRotation = _body.zRotation + _barrel.zRotation;
    CGPoint direction = [self directionFromRotation:(combinedRotation)];
    
    return direction;
}

- (CGFloat)angleBetweenGunHeadingDirectionAndWorldPosition:(CGPoint)position {
    // vector between robot's gun position and target position
    CGPoint directionVector = CGPointMake(position.x - _body.position.x, position.y - _body.position.y);
    CGPoint currentHeading = [self gunHeadingDirection];
    
    return roundf(radToDeg(angleSigned(directionVector, currentHeading)));
}

- (CGFloat)currentTimestamp {
    return self.gameBoard.currentTimestamp;
}

- (CGSize)arenaDimensions {
    return [self.gameBoard dimensions];
}

- (CGSize)robotBodySize {
    return _body.size;
}

- (CGPoint)position {
    return _body.position;
}

#pragma mark - Events

- (void)_scannedRobot:(Robot*)robot atPosition:(CGPoint)position {
    dispatch_group_async(mainQueueGroup, _mainQueue, ^{
        [self scannedRobot:robot atPosition:position];
    });
}

- (void)_hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {
    dispatch_group_async(mainQueueGroup, _mainQueue, ^{
        // now that action is being executed, check if information about collision is still valid
        RobotWallHitDirection currentWallHitDirection = [self.gameBoard currentWallHitDirectionForRobot:self];
        if (currentWallHitDirection == RobotWallHitDirectionNone || currentWallHitDirection != hitDirection) {
            return;
        } else {
            [self hitWall:hitDirection hitAngle:angle];
        }
    });
}

- (void)_gotHit {
    self.health--;
    [self updateHealthBar];
    
    if (self.health <= 0) {
        [self.gameBoard robotDied:self];
    } else {
        dispatch_group_async(mainQueueGroup, _mainQueue, ^{
            [self gotHit];
        });
    }
}

- (void)_bombHit {
    self.health -= 3;
    [self updateHealthBar];
    if (self.health <= 0) {
        [self.gameBoard robotDied:self];
    }
}

- (void)_bulletHitEnemy:(Bullet*)bullet {
    dispatch_group_async(mainQueueGroup, _mainQueue, ^{
        [self bulletHitEnemyAt: bullet.position];
    });
}

- (void)cancelActiveAction {
    if (_currentRobotAction != nil) {
        [_currentRobotAction cancel];
    }
}

#pragma mark - Event Handlers

- (void)gotHit{};
- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {};
- (void)scannedRobot:(Robot*)robot atPosition:(CGPoint)position {};
- (void)run {};
- (void)bulletHitEnemyAt:(CGPoint)position {}

#pragma mark - UI Updates

- (void)updateHealthBar {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.health > 0) {
            _healthBar.alpha = 1.0;
            _healthBar.yScale = self.health / (ROBOT_INITIAL_LIFES * 1.f);
            
            if (self.health >= ROBOT_INITIAL_LIFES * 3 / 4) {
                _healthBar.color = [SKColor colorWithRed:170.f/255 green:1.f blue:151.f/255 alpha:1.f];
            } else if (self.health >= ROBOT_INITIAL_LIFES * 2 / 4) {
                _healthBar.color = [SKColor colorWithRed:1.f green:249.f/255 blue:149.f/255 alpha:1.f];
            } else if (self.health >= ROBOT_INITIAL_LIFES * 1 / 4) {
                _healthBar.color = [SKColor colorWithRed:1.f green:190.f/255 blue:138.f/255 alpha:1.f];
            } else {
                _healthBar.color = [SKColor colorWithRed:1.f green:121.f/255 blue:127.f/255 alpha:1.f];
            }
            
        } else {
            _healthBar.alpha = 0.0;
        }
    });
}

#pragma mark - Utils

- (CGPoint)directionFromRotation:(CGFloat)objectRotation {
    CGFloat rotation = objectRotation;
    CGFloat x = cos(rotation);
    CGFloat y = sin(rotation);
    
    return CGPointMake(x, y);
}

- (Robot*)copyWithZone:(NSZone *)zone {
    Robot *newRobot = [[[self class] allocWithZone:zone] init];
    newRobot->_creator = [_creator copyWithZone:zone];
    newRobot->_robotClass = [_robotClass copyWithZone:zone];
    
    return newRobot;
}

@end
