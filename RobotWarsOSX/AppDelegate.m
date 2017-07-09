//
//  AppDelegate.m
//  RobotWarsOSX
//
//  Created by Dion Larson on 6/4/16.
//  Copyright (c) 2016 Make School. All rights reserved.
//

#import "AppDelegate.h"
#import "MainScene.h"
#import "TournamentScene.h"
#import "Configuration.h"
#import "TournamentConfiguration.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    SKScene *scene;
    if (TOURNAMENT) {
        scene = [TournamentScene nodeWithFileNamed:@"TournamentScene"];
    } else {
        scene = [MainScene nodeWithFileNamed:@"MainScene"];
        [(MainScene*) scene initWithRobotClassOne:robotClass1 andRobotClassTwo:robotClass2];
    }
    
    scene.scaleMode = SKSceneScaleModeAspectFit;
    // Present the scene.
    [self.skView presentScene:scene];

    /* Sprite Kit applies additional optimizations to improve rendering performance */
    self.skView.ignoresSiblingOrder = YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
