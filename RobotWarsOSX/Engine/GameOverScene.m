//
//  GameOverScene.m
//  RobotWar
//
//  Created by Benjamin Encz on 03/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GameOverScene.h"
#import "TournamentScene.h"
#import "TournamentConfiguration.h"

@implementation GameOverScene {
  SKLabelNode *_winnerLabel;
  SKLabelNode *_countdownLabel;
  int countdown;
}

- (void)didMoveToView:(SKView *)view
{
    _winnerLabel = (SKLabelNode*) [self childNodeWithName:@"winnerLabel"];
    _countdownLabel = (SKLabelNode*) [self childNodeWithName:@"countdownLabel"];
    
    countdown = COUNTDOWN;
  
    if (TOURNAMENT) {
      _countdownLabel.text = [NSString stringWithFormat:@"%d", countdown];
      
      SKAction *wait = [SKAction waitForDuration:1.f];
      SKAction *performSelector = [SKAction performSelector:@selector(updateCountdown) onTarget:self];
      SKAction *sequence = [SKAction sequence:@[performSelector, wait]];
      SKAction *repeat = [SKAction repeatActionForever:sequence];
      [self runAction:repeat withKey:@"updateCountdown"];
      
    } else {
      _countdownLabel.alpha = 0.0;
    }
    
    [self displayWinMessage];
}

- (void)cleanup
{
  [self removeActionForKey:@"updateCountdown"];
}

- (void)loadTournamentScene
{
    TournamentScene* tournamentScene = [TournamentScene nodeWithFileNamed:@"TournamentScene"];
    SKTransition *transition = [SKTransition crossFadeWithDuration:0.3f];
    
    [tournamentScene updateWithResults:@{@"Winner": self.winnerClass, @"Loser": self.loserClass}];
    [self.view presentScene:tournamentScene transition:transition];
}

- (void)displayWinMessage
{
    if (!self.winnerName || [self.winnerName isEqualToString:@""])
        _winnerLabel.text = [NSString stringWithFormat:@"%@ wins this battle!", self.winnerClass];
    else
        _winnerLabel.text = [NSString stringWithFormat:@"%@'s %@ wins this battle!", self.winnerName, self.winnerClass];
}

- (void)updateCountdown
{
  countdown--;
  
  _countdownLabel.text = [NSString stringWithFormat:@"%d", countdown];
  
  if (countdown <= 0)
  {
    [self loadTournamentScene];
  }
}

@end
