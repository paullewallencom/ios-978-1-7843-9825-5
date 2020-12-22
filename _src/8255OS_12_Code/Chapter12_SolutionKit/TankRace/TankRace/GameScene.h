//
//  GameScene.h
//  TankRace
//

//  Copyright (c) 2014 RahulBorawar. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@protocol GameSceneDelegate <NSObject>

- (void)showMCBrowserControllerForSession:(MCSession*)session
                              serviceType:(NSString*)serviceType;
@end

@interface GameScene : SKScene

@property (nonatomic, weak) id<GameSceneDelegate> gameSceneDelegate;

#pragma mark - Public Methods

- (void)startGame;
- (void)discardSession;

@end
