//
//  TurretRobotSwift.swift
//  RobotWar
//
//  Created by Dion Larson on 7/2/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation

class TurretRobot: Robot {
    
    enum RobotState {                    // enum for keeping track of RobotState
        case scanning, firing
    }
    
    var currentRobotState: RobotState = .scanning
    var lastEnemyHit = CGFloat(0.0)
    let gunToleranceAngle = CGFloat(2.0)
    let firingTimeout = CGFloat(2.5)
    
    override func run() {
        while true {
            switch currentRobotState {
            case .scanning:
                turnGunRight(90)
            case .firing:
                if currentTimestamp() - lastEnemyHit > firingTimeout {
                    cancelActiveAction()
                    currentRobotState = .scanning
                } else {
                    shoot()
                }
            }
        }
    }
    
    override func scannedRobot(_ robot: Robot!, atPosition position: CGPoint) {
        turnToEnemyPosition(position)
        
        lastEnemyHit = currentTimestamp()
        currentRobotState = .firing
    }
    
    override func gotHit() {
        // unimplemented
    }
    
    override func hitWall(_ hitDirection: RobotWallHitDirection, hitAngle: CGFloat) {
        // unimplemented
    }
    
    override func bulletHitEnemy(at position: CGPoint) {
        lastEnemyHit = currentTimestamp()
        currentRobotState = .firing
    }
    
    func turnToEnemyPosition(_ position: CGPoint) {
        cancelActiveAction()
        
        // calculate angle between turret and enemey
        let angleBetweenTurretAndEnemy = angleBetweenGunHeadingDirectionAndWorldPosition(position)
        
        // turn if necessary
        if angleBetweenTurretAndEnemy > gunToleranceAngle {
            turnGunRight(Int(abs(angleBetweenTurretAndEnemy)))
        } else if angleBetweenTurretAndEnemy < -gunToleranceAngle {
            turnGunLeft(Int(abs(angleBetweenTurretAndEnemy)))
        }
    }
    
}
