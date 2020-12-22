//
//  GameScene.m
//  SteeringBehaviors
//
//  Created by Bhanu Birani on 25/12/14.
//  Copyright (c) 2014 mb. All rights reserved.
//

#import "GameScene.h"
#import "Player.h"

@implementation GameScene {
    float lastTime;
    Player * newplayer;
    SteeringBehaviorType behaviourType;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        
        newplayer = [self createPlayer];
        newplayer.position = CGPointMake(size.width/2, size.height/2);
        
        behaviourType = Wander;
        newplayer.behaviourType = behaviourType;
        
        if (behaviourType == Seek) {
            newplayer.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(30, 30)];
            newplayer.physicsBody.friction = 1.0f;
            newplayer.physicsBody.linearDamping = 1.0f;
        }
        
        if (behaviourType == Wander) {
            newplayer.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(30, 30)];
            SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
            self.physicsBody = borderBody;
            self.physicsBody.friction = 0.0f;
        }
    }
    return self;
}

- (Player *)createPlayer
{
    Player *plyr = [Player playerObject];
    [self addChild:plyr];
    
    return plyr;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        NSLog(@"%@", NSStringFromCGPoint(location));
        
        newplayer.target = location;
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    if (!CGPointEqualToPoint(newplayer.target, CGPointZero)) {
        float deltaTime = currentTime - lastTime;
        [newplayer update:deltaTime];
        lastTime = currentTime;
    }
}

@end
