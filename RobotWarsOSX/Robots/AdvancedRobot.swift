//
//  AdvancedRobotSwift.swift
//  RobotWar
//
//  Created by Dion Larson on 7/2/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation

class AdvancedRobot: Robot {
    
    enum RobotState {                    // enum for keeping track of RobotState
        case `default`, turnaround, firing, searching
    }
    
    var currentRobotState: RobotState = .default {
        didSet {
            actionIndex = 0
        }
    }
    var actionIndex = 0                 // index in sub-state machines, could use enums
    // but will make harder to quickly add new states
    
    var lastKnownPosition = CGPoint(x: 0, y: 0)
    var lastKnownPositionTimestamp = CGFloat(0.0)
    let firingTimeout = CGFloat(1.0)
    
    override func run() {
        while true {
            switch currentRobotState {
            case .default:
                performNextDefaultAction()
            case .searching:
                performNextSearchingAction()
            case .firing:
                performNextFiringAction()
            case .turnaround:               // ignore Turnaround since handled in hitWall
                break
            }
        }
    }
    
    func performNextDefaultAction() {
        // uses actionIndex with switch in case you want to expand and add in more actions
        // to your initial state -- first thing robot does before scanning another robot
        switch actionIndex % 1 {          // should be % of number of possible actions
        case 0:
            moveAhead(25)
            currentRobotState = .searching
        default:
            break
        }
        actionIndex += 1
    }
    
    func performNextSearchingAction() {
        switch actionIndex % 4 {          // should be % of number of possible actions
        case 0:
            moveAhead(50)
        case 1:
            turnLeft(20)
        case 2:
            moveAhead(50)
        case 3:
            turnRight(20)
        default:
            break
        }
        actionIndex += 1
    }
    
    func performNextFiringAction() {
        if currentTimestamp() - lastKnownPositionTimestamp > firingTimeout {
            currentRobotState = .searching
        } else {
            let angle = Int(angleBetweenGunHeadingDirectionAndWorldPosition(lastKnownPosition))
            if angle >= 0 {
                turnGunRight(abs(angle))
            } else {
                turnGunLeft(abs(angle))
            }
            shoot()
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
    
    override func hitWall(_ hitDirection: RobotWallHitDirection, hitAngle angle: CGFloat) {
        cancelActiveAction()
        
        // save old state
        let previousState = currentRobotState
        currentRobotState = .turnaround
        
        // always turn directly away from wall
        if angle >= 0 {
            turnLeft(Int(abs(angle)))
        } else {
            turnRight(Int(abs(angle)))
        }
        
        // leave wall
        moveAhead(20)
        
        // reset to old state
        currentRobotState = previousState
    }
    
    override func bulletHitEnemy(at position: CGPoint) {
        // unimplemented
    }
    
}
