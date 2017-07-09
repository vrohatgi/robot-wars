//
//  SimpleRobotSwift.swift
//  RobotWar
//
//  Created by Dion Larson on 7/2/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation

class SimpleRobot: Robot {
    
    override func run() {
        while true {
            moveAhead(80)
            turnRight(20)
            moveAhead(100)
            shoot()
            turnLeft(10)
        }
    }
    
    override func scannedRobot(_ robot: Robot!, atPosition position: CGPoint) {
        // unimplemented
    }
    
    override func gotHit() {
        shoot()
        turnLeft(45)
        moveAhead(100)
    }
    
    override func hitWall(_ hitDirection: RobotWallHitDirection, hitAngle: CGFloat) {
        cancelActiveAction()
        
        switch hitDirection {
        case .front:
            turnRight(180)
            moveAhead(20)
        case .rear:
            moveAhead(80)
        case .left:
            turnRight(90)
            moveAhead(20)
        case .right:
            turnLeft(90)
            moveAhead(20)
        case .none:           // should never be none, but switch must be exhaustive
            break
        }
    }
    
    override func bulletHitEnemy(at position: CGPoint) {
        // unimplemented
    }
    
}
