//
//  Helpers.c
//  RobotWar
//
//  Created by Benjamin Encz on 05/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Helpers.h"

CGFloat radToDeg(CGFloat rad) {
    return rad * (180/M_PI);
}

CGFloat degToRad(CGFloat deg) {
    return deg * (M_PI/180);
}

CGFloat angleSigned(CGPoint a, CGPoint b) {
    return atan2(b.y, b.x) - atan2(a.y, a.x);
}

CGFloat distanceBetween(CGPoint a, CGPoint b) {
    return sqrt(pow((a.x-b.x), 2) + pow((a.y-b.y), 2));
}

CGPoint pointFromAngle(CGFloat angle, CGFloat radius) {
    return CGPointMake(radius * cos(angle), radius * sin(angle));
}

RobotWallHitDirection radAngleToRobotWallHitDirection(CGFloat rad) {
    if (rad >= -135 && rad <= -46) {
        return RobotWallHitDirectionLeft;
    } else if ((rad >= 136 && rad <= 180) || (rad >= -180 && rad <= -136)) {
        return RobotWallHitDirectionFront;
    } else if  (rad >= 46 && rad <= 135){
        return RobotWallHitDirectionRight;
    } else  {
        return RobotWallHitDirectionRear;
    }
}


