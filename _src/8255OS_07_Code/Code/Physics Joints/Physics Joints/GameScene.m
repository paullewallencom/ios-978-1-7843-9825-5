//
//  GameScene.m
//  Physics Joints
//
//  Created by Bhanu Birani on 18/11/14.
//  Copyright (c) 2014 mb. All rights reserved.
//

#import "GameScene.h"

typedef NS_OPTIONS(uint32_t, CNPhysicsCategory)
{
    GFPhysicsCategoryWorld    = 1 << 0,  // 0001 = 1
    GFPhysicsCategoryRectangle  = 1 << 1,  // 0010 = 2
    GFPhysicsCategorySquare  = 1 << 2,  // 0100 = 2
};

SKLabelNode* collisionLabel;

@implementation GameScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        self.physicsWorld.gravity = CGVectorMake(0, -0.5);
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody.friction = 0.0f;
        self.physicsWorld.contactDelegate = self;
        
        [self createCollisionDetectionOnScene:self];
    }
    return self;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

#pragma mark Create Bodies Without Joint

-(void)createPhysicsBodiesOnScene:(SKScene*)scene {
    //Adding Rectangle
    SKSpriteNode* backBone = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size:CGSizeMake(20, 200)];
    backBone.position = CGPointMake(CGRectGetWidth(self.frame)/2.0, CGRectGetHeight(self.frame)/2.0);
    backBone.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:backBone.size];
    [scene addChild:backBone];
    
    
    //Adding Square
    SKSpriteNode* head = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(40, 40)];
    head.position = CGPointMake(backBone.position.x, backBone.position.y-40);
    head.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:head.size];
    [scene addChild:head];
    
}

#pragma mark Creating a Pin Joint

-(void)createPinJointOnScene:(SKScene*)scene {
    //Adding Rectangle
    SKSpriteNode* backBone = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size:CGSizeMake(20, 200)];
    backBone.position = CGPointMake(CGRectGetWidth(self.frame)/2.0, CGRectGetHeight(self.frame)/2.0);
    backBone.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:backBone.size];
    backBone.physicsBody.categoryBitMask = GFPhysicsCategoryRectangle;
    backBone.physicsBody.collisionBitMask = GFPhysicsCategoryWorld;
    [scene addChild:backBone];
    
    
    //Adding Square
    SKSpriteNode* head = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(40, 40)];
    head.position = CGPointMake(backBone.position.x+5, backBone.position.y-40);
    head.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:head.size];
    head.physicsBody.categoryBitMask = GFPhysicsCategorySquare;
    head.physicsBody.collisionBitMask = GFPhysicsCategoryWorld;
    [scene addChild:head];
    
    //Pinning Rectangle and Square
    NSLog(@"Head position %@", NSStringFromCGPoint(head.position));
    SKPhysicsJointPin* pin =[SKPhysicsJointPin jointWithBodyA:backBone.physicsBody bodyB:head.physicsBody anchor:CGPointMake(head.position.x-5, head.position.y)];
    [scene.physicsWorld addJoint:pin];
}

#pragma mark Creating a Fixed Joint

-(void)createFixedJointOnScene:(SKScene*)scene {
    //Adding Rectangle
    SKSpriteNode* backBone = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size:CGSizeMake(20, 200)];
    backBone.position = CGPointMake(CGRectGetWidth(self.frame)/2.0, CGRectGetHeight(self.frame)/2.0);
    backBone.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:backBone.size];
    backBone.physicsBody.categoryBitMask = GFPhysicsCategoryRectangle;
    backBone.physicsBody.collisionBitMask = GFPhysicsCategoryWorld;
    [scene addChild:backBone];
    
    
    //Adding Square
    SKSpriteNode* head = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(40, 40)];
    head.position = CGPointMake(backBone.position.x+5, backBone.position.y-40);
    head.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:head.size];
    head.physicsBody.categoryBitMask = GFPhysicsCategorySquare;
    head.physicsBody.collisionBitMask = GFPhysicsCategoryWorld;
    [scene addChild:head];
    
    //Pinning Rectangle and Square
    NSLog(@"Head position %@", NSStringFromCGPoint(head.position));
    SKPhysicsJointFixed* pin =[SKPhysicsJointFixed jointWithBodyA:backBone.physicsBody bodyB:head.physicsBody anchor:CGPointMake(head.position.x-5, head.position.y)];
    [scene.physicsWorld addJoint:pin];
}

#pragma mark Creating a Sliding Joint

-(void)createSlidingJointOnScene:(SKScene*)scene {
    SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Futura-Medium"];
    label.text = @"An upward impulse is applied to the square every few seconds.";
    label.fontSize = 14;
    label.position = CGPointMake(220, scene.view.frame.size.height-100);
    [scene addChild:label];
    
    //Adding Rectangle
    SKSpriteNode* backBone = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size:CGSizeMake(20, 200)];
    backBone.position = CGPointMake(CGRectGetWidth(self.frame)/2.0, CGRectGetHeight(self.frame)/2.0);
    backBone.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:backBone.size];
    backBone.physicsBody.categoryBitMask = GFPhysicsCategoryRectangle;
    backBone.physicsBody.collisionBitMask = GFPhysicsCategoryWorld;
    backBone.physicsBody.affectedByGravity = NO;
    backBone.physicsBody.allowsRotation = NO;
    [scene addChild:backBone];
    
    //Adding Square
    SKSpriteNode* head = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(40, 40)];
    head.position = CGPointMake(backBone.position.x, backBone.position.y-40);
    head.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:head.size];
    head.physicsBody.categoryBitMask = GFPhysicsCategorySquare;
    head.physicsBody.collisionBitMask = GFPhysicsCategoryWorld;
    [scene addChild:head];
    
    //Pinning Rectangle and Square
    NSLog(@"Head position %@", NSStringFromCGPoint(head.position));
    SKPhysicsJointSliding* pin =[SKPhysicsJointSliding jointWithBodyA:backBone.physicsBody bodyB:head.physicsBody anchor:head.position axis:CGVectorMake(0, 1)];
    pin.shouldEnableLimits = YES;
    pin.upperDistanceLimit = 200;
    pin.lowerDistanceLimit = -100;
    
    [scene.physicsWorld addJoint:pin];
    
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(applyImpulseUpwards:) userInfo:@{@"body":head.physicsBody,@"impulse":@(25)} repeats:YES];
}

-(void)applyImpulseUpwards:(NSTimer*)timer {
    NSDictionary* dict = [timer userInfo];
    SKPhysicsBody* body = dict[@"body"];
    
    CGVector impulse = CGVectorMake(0, [dict[@"impulse"] intValue]);
    
    [body applyImpulse:impulse];
}

#pragma mark Creating a Spring Joint

-(void)createSpringJointOnScene:(SKScene*)scene {
    SKSpriteNode* backBone = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size:CGSizeMake(20, 200)];
    backBone.position = CGPointMake(CGRectGetWidth(self.frame)/2.0, CGRectGetHeight(self.frame)/2.0);
    backBone.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:backBone.size];
    backBone.physicsBody.categoryBitMask = GFPhysicsCategoryRectangle;
    backBone.physicsBody.collisionBitMask = GFPhysicsCategoryWorld;
    [scene addChild:backBone];
    
    
    //Adding Square
    SKSpriteNode* head = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(40, 40)];
    head.position = CGPointMake(backBone.position.x, backBone.position.y+backBone.size.height/2.0+40);
    head.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:head.size];
    head.physicsBody.categoryBitMask = GFPhysicsCategorySquare;
    head.physicsBody.collisionBitMask = GFPhysicsCategoryWorld;
    [scene addChild:head];
    
    //Pinning Rectangle and Square
    NSLog(@"Head position %@", NSStringFromCGPoint(head.position));
    SKPhysicsJointSpring* pin =[SKPhysicsJointSpring jointWithBodyA:backBone.physicsBody bodyB:head.physicsBody anchorA:head.position anchorB:CGPointMake(backBone.position.x, backBone.position.y+backBone.size.height/2.0)];
    pin.damping = 0.5;
    pin.frequency = 0.5;
    [scene.physicsWorld addJoint:pin];
}

#pragma mark Creating a Limit Joint

-(void)createLimitJointOnScene:(SKScene*)scene {
    
    SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Futura-Medium"];
    label.text = @"An upward impulse is applied to the square every few seconds.";
    label.fontSize = 14;
    label.position = CGPointMake(220, scene.view.frame.size.height-100);
    [scene addChild:label];
    
    SKSpriteNode* backBone = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size:CGSizeMake(20, 200)];
    backBone.position = CGPointMake(CGRectGetWidth(self.frame)/2.0, CGRectGetHeight(self.frame)/2.0);
    backBone.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:backBone.size];
    backBone.physicsBody.categoryBitMask = GFPhysicsCategoryRectangle;
    backBone.physicsBody.collisionBitMask = GFPhysicsCategorySquare;
    backBone.physicsBody.contactTestBitMask = GFPhysicsCategorySquare;
    backBone.physicsBody.dynamic = YES;
    [scene addChild:backBone];
    
    
    //Adding Square
    SKSpriteNode* head = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(40, 40)];
    head.position = CGPointMake(backBone.position.x, backBone.position.y+backBone.size.height/2.0+40);
    head.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:head.size];
    head.physicsBody.categoryBitMask = GFPhysicsCategorySquare;
    head.physicsBody.collisionBitMask = GFPhysicsCategoryRectangle;
    head.physicsBody.contactTestBitMask = GFPhysicsCategoryRectangle;
    head.physicsBody.dynamic = YES;
    [scene addChild:head];
    
    //Pinning Rectangle and Square
    NSLog(@"Head position %@", NSStringFromCGPoint(head.position));
    SKPhysicsJointLimit* pin =[SKPhysicsJointLimit jointWithBodyA:backBone.physicsBody bodyB:head.physicsBody anchorA:head.position anchorB:CGPointMake(backBone.position.x, backBone.position.y+backBone.size.height/2.0)];
    pin.maxLength = 100;
    [scene.physicsWorld addJoint:pin];
    
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(applyImpulseUpwards:) userInfo:@{@"body":head.physicsBody,@"impulse":@(50)} repeats:YES];
}

#pragma mark Collision detection methods

- (void)createCollisionDetectionOnScene:(SKScene*)scene {
    collisionLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-Medium"];
    collisionLabel.text = @"Collision detected";
    collisionLabel.fontSize = 18;
    collisionLabel.fontColor = [SKColor whiteColor];
    collisionLabel.position = CGPointMake(CGRectGetWidth(self.frame)/2.0, CGRectGetHeight(self.frame)/1.2);
    collisionLabel.alpha = 0.0f;
    [scene addChild:collisionLabel];
    
    SKSpriteNode* backBone = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size:CGSizeMake(20, 200)];
    backBone.position = CGPointMake(CGRectGetWidth(self.frame)/2.0, CGRectGetHeight(self.frame)/2.0);
    backBone.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:backBone.size];
    backBone.physicsBody.categoryBitMask = GFPhysicsCategoryRectangle;
    backBone.physicsBody.collisionBitMask = GFPhysicsCategorySquare;
    backBone.physicsBody.contactTestBitMask = GFPhysicsCategorySquare;
    backBone.physicsBody.dynamic = YES;
    [scene addChild:backBone];
    
    
    //Adding Square
    SKSpriteNode* head = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(40, 40)];
    head.position = CGPointMake(backBone.position.x, backBone.position.y+backBone.size.height/2.0+40);
    head.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:head.size];
    head.physicsBody.categoryBitMask = GFPhysicsCategorySquare;
    head.physicsBody.collisionBitMask = GFPhysicsCategoryRectangle;
    head.physicsBody.contactTestBitMask = GFPhysicsCategoryRectangle;
    head.physicsBody.dynamic = YES;
    [scene addChild:head];
    
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(applyImpulseUpwards:) userInfo:@{@"body":head.physicsBody,@"impulse":@(50)} repeats:YES];
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    NSLog(@"did %u, %u", contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask);
    SKSpriteNode *firstNode, *secondNode;
    
    firstNode = (SKSpriteNode *)contact.bodyA.node;
    secondNode = (SKSpriteNode *) contact.bodyB.node;
    
    if (firstNode.physicsBody.categoryBitMask == GFPhysicsCategoryRectangle && secondNode.physicsBody.categoryBitMask == GFPhysicsCategorySquare) {
        
        SKAction *fadeIn = [SKAction fadeAlphaTo:1.0f duration:0.2];
        SKAction *fadeOut = [SKAction fadeAlphaTo:0.0f duration:0.2];
        [collisionLabel runAction:fadeIn completion:^{
            [collisionLabel runAction:fadeOut];
        }];
    }
    
}

@end
