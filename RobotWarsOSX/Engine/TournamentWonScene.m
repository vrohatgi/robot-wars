//
//  TournamentWonScene.m
//  RobotWar
//
//  Created by Daniel Haaser on 7/6/14.
//  Copyright (c) 2014 Make School. All rights reserved.
//

#import "TournamentWonScene.h"

@implementation TournamentWonScene
{
    SKLabelNode* robotLabel;
}

- (void)didMoveToView:(SKView *)view
{
    robotLabel = (SKLabelNode*) [self childNodeWithName:@"robotLabel"];
    robotLabel.text = _winningRobot;
}

- (void)setWinningRobot:(NSString *)winningRobot
{
    if (winningRobot)
    {
        _winningRobot = [winningRobot copy];
    }
}

@end
