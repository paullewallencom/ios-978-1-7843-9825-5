//
//  Player.h
//  SteeringBehaviors
//
//  Created by Bhanu Birani on 25/12/14.
//  Copyright (c) 2014 mb. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum : NSUInteger {
    Seek,
    Arrive,
    Flee,
    Wander,
    Evade
} SteeringBehaviorType;

@interface Player : SKSpriteNode

@property (assign) SteeringBehaviorType behaviourType;
@property (assign) CGPoint target;

+ (Player*) playerObject;

- (void) update:(float)deltaTime;

@end
