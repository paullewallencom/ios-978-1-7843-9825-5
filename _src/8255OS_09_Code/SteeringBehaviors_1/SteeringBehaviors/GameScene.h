//
//  GameScene.h
//  SteeringBehaviors
//

//  Copyright (c) 2014 mb. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene {
    SKSpriteNode* head;
    CGVector seekLocation;
}

@property (nonatomic, assign) CGVector positionV2D;
@property (nonatomic, assign) CGVector velocityV2D;
@property (nonatomic, assign) CGVector steeringForce;

@end
