//
//  Bullet.h
//  RobotWar
//
//  Created by Benjamin Encz on 02/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class Robot;

@interface Bullet : SKSpriteNode

@property (nonatomic, weak) Robot *bulletOwner;

@end
