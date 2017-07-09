//
//  MyRobot.swift
//  RobotWarsOSX
//
//  Created by vanya rohatgi on 6/28/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation

class TheTerminator: Robot {
    
    enum RobotState {                    // enum for keeping track of RobotState
        case firstMove, camping, firing, scanning
    }
    
    var currentRobotState: RobotState = .firstMove
    
    var lastKnownPosition = CGPoint(x: 0, y: 0)
    var lastKnownPositionTimestamp = CGFloat(0.0)
    var lastEnemyHit = CGFloat(0.0)
    let firingTimeout = CGFloat(1.0)
    let gunToleranceAngle = CGFloat(2.0)
    
    override func run() {
            while true {
                switch currentRobotState {
                case .firstMove:
                    performFirstMoveAction()
                case .scanning:
                    let i = 1
                    while i < 2 {
                        turnToCenter()
                        shoot()
                        for _ in 0...9 {
                            turnRight(5)
                            shoot()
                        }
                        for _ in 0...18 {
                            turnLeft(5)
                            shoot()
                        }}
                case .camping:
                    shoot()
                    performNextFiringAction()
                case .firing:
                    if currentTimestamp() - lastEnemyHit > firingTimeout {
                        cancelActiveAction()
                        currentRobotState = .scanning
                    } else {
                        shoot()
                    }
                default:
                    performFirstMoveAction()
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
            }}
          // back into closest corner
        currentPosition = position()
        if currentPosition.y < arenaSize.height/2 {
            moveBack(Int(currentPosition.y - bodyLength))
        } else {
            moveBack(Int(arenaSize.height - (currentPosition.y + bodyLength)))
        }
        
        // turn gun towards center, shoot, camp out
        let i = 1
        while i < 2 {
            turnToCenter()
            shoot()
            for _ in 0...9 {
                turnRight(5)
                shoot()
            }
            for _ in 0...18 {
                turnLeft(5)
                shoot()
            }
        }
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
        cancelActiveAction()
        turnToEnemyPosition(position)
        for _ in 0...21 {
            shoot()
        }
        
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
    
//if bullet hits enemy -> keeps shooting in that direction
    override func bulletHitEnemy(at position: CGPoint) {
        cancelActiveAction()
        for _ in 0...21 {
            shoot()
        }
        let i = 1
        while i < 2 {
            turnToCenter()
            shoot()
            for _ in 0...9 {
                turnRight(5)
                shoot()
            }
            for _ in 0...18 {
                turnLeft(5)
                shoot()
            }
        }
//
//        lastEnemyHit = currentTimestamp()
//        currentRobotState = .firing
    }
    
    override func gotHit() {
        cancelActiveAction()
        lastEnemyHit = currentTimestamp()
        currentRobotState = .firing
    }
    
}

