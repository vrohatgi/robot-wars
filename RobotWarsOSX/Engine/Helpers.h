//
//  Helpers.h
//  RobotWar
//
//  Created by Benjamin Encz on 04/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#ifndef RobotWar_Helpers_h
#define RobotWar_Helpers_h

#import "Robot.h"

extern CGFloat radToDeg(CGFloat rad);
extern CGFloat degToRad(CGFloat deg);
CGFloat angleSigned(CGPoint a, CGPoint b);
CGPoint pointFromAngle(CGFloat angle, CGFloat radius);
CGFloat distanceBetween(CGPoint a, CGPoint b);
extern RobotWallHitDirection radAngleToRobotWallHitDirection(CGFloat rad);

#endif
