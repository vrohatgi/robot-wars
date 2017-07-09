//
//  LiveRobotSwift.swift
//  RobotWar
//
//  Created by Dion Larson on 7/2/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation

class CamperRobot: Robot {
    
    enum RobotState {                    // enum for keeping track of RobotState
        case firstMove, camping, firing
    }
    
    var currentRobotState: RobotState = .firstMove
    
    var lastKnownPosition = CGPoint(x: 0, y: 0)
    var lastKnownPositionTimestamp = CGFloat(0.0)
    let firingTimeout = CGFloat(1.0)
    let gunToleranceAngle = CGFloat(2.0)
    
    override func run() {
        while true {
            switch currentRobotState {
            case .firstMove:
                performFirstMoveAction()
            case .camping:
                shoot()
            case .firing:
                performNextFiringAction()
            }
        }
    }
    
    func performFirstMoveAction() {
        let arenaSize = arenaDimensions()
        let bodyLength = robotBodySize().width
        
        // find and turn towards closest corner
        var currentPosition = position()
        if currentPosition.y < arenaSize.height / 2 {
            if currentPosition.x < arenaSize.width/2 {
                // bottom left
                turnLeft(90)
            } else {
                // bottom right
                turnRight(90)
            }
        } else {
            if currentPosition.x < arenaSize.width/2 {
                // top left
                turnRight(90)
            } else {
                // top right
                turnLeft(90)
            }
        }
        
        // back into closest corner
        currentPosition = position()
        if currentPosition.y < arenaSize.height/2 {
            moveBack(Int(currentPosition.y - bodyLength))
        } else {
            moveBack(Int(arenaSize.height - (currentPosition.y + bodyLength)))
        }
        
        // turn gun towards center, shoot, camp out
        turnToCenter()
        shoot()
        currentRobotState = .camping
    }
    
    func performNextFiringAction() {
        if currentTimestamp() - lastKnownPositionTimestamp > firingTimeout {
            turnToCenter()
            currentRobotState = .camping
        } else {
            turnToEnemyPosition(lastKnownPosition)
        }
        shoot()
    }
    
    func turnToCenter() {
        let arenaSize = arenaDimensions()
        let angle = Int(angleBetweenGunHeadingDirectionAndWorldPosition(CGPoint(x: arenaSize.width/2, y: arenaSize.height/2)))
        if angle < 0 {
            turnGunLeft(abs(angle))
        } else {
            turnGunRight(angle)
        }
    }
    
    override func scannedRobot(_ robot: Robot!, atPosition position: CGPoint) {
        if currentRobotState != .firing {
            cancelActiveAction()
        }
        
        lastKnownPosition = position
        lastKnownPositionTimestamp = currentTimestamp()
        currentRobotState = .firing
    }
    
    override func gotHit() {
        // unimplemented
    }
    
    override func hitWall(_ hitDirection: RobotWallHitDirection, hitAngle: CGFloat) {
        // unimplemented
    }
    
    override func bulletHitEnemy(at position: CGPoint) {
        shoot()
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
