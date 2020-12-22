//
//  GameScene.m
//  PhysicsSimulation
//
//  Created by Bhanu Birani on 05/11/14.
//  Copyright (c) 2014 mb. All rights reserved.
//

#import "GameScene.h"

static NSString* ballCategoryName = @"ball";
static NSString* paddleCategoryName = @"paddle";
static NSString* blockCategoryName = @"block";
static NSString* blockNodeCategoryName = @"blockNode";

@interface GameScene()

@property (nonatomic) BOOL isPaddleTapped;

@end

@implementation GameScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        SKSpriteNode* background = [SKSpriteNode spriteNodeWithImageNamed:@"bg.png"];
        background.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addChild:background];
        
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        
        // 1 Create a physics body that borders the screen
        SKPhysicsBody* gameborderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        // 2 Set physicsBody of scene to borderBody
        self.physicsBody = gameborderBody;
        // 3 Set the friction of that physicsBody to 0
        self.physicsBody.friction = 0.0f;
        
        
        // 1
        SKSpriteNode* circlularObject = [SKSpriteNode spriteNodeWithImageNamed: @"ball.png"];
        circlularObject.name = ballCategoryName;
        circlularObject.position = CGPointMake(self.frame.size.width/3, self.frame.size.height/3);
        [self addChild:circlularObject];
        
        // 2
        circlularObject.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:circlularObject.frame.size.width/2];
        // 3
        circlularObject.physicsBody.friction = 0.0f;
        // 4
        circlularObject.physicsBody.restitution = 1.0f;
        // 5
        circlularObject.physicsBody.linearDamping = 0.0f;
        // 6
        circlularObject.physicsBody.allowsRotation = NO;
        
        [circlularObject.physicsBody applyImpulse:CGVectorMake(10.0f, -10.0f)];

        SKSpriteNode* block = [[SKSpriteNode alloc] initWithImageNamed: @"block.png"];
        block.name = paddleCategoryName;
        block.position = CGPointMake(CGRectGetMidX(self.frame), block.frame.size.height * 0.6f);
        [self addChild:block];
        block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:block.frame.size];
        block.physicsBody.restitution = 0.1f;
        block.physicsBody.friction = 0.4f;
        // make physicsBody static
        block.physicsBody.dynamic = NO;
    }
    return self;
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    
    SKPhysicsBody* body = [self.physicsWorld bodyAtPoint:touchLocation];
    if (body && [body.node.name isEqualToString: paddleCategoryName]) {
        NSLog(@"touch began on paddle");
        self.isPaddleTapped = YES;
    }
}

-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {

    if (self.isPaddleTapped) {
        // 2 Get touch location
        UITouch* touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInNode:self];
        CGPoint previousLocation = [touch previousLocationInNode:self];
        // 3 Get node for paddle
        SKSpriteNode* paddle = (SKSpriteNode*)[self childNodeWithName: paddleCategoryName];
        // 4 Calculate new position along x for paddle
        int paddleX = paddle.position.x + (touchLocation.x - previousLocation.x);
        // 5 Limit x so that the paddle will not leave the screen to left or right
        paddleX = MAX(paddleX, paddle.size.width/2);
        paddleX = MIN(paddleX, self.size.width - paddle.size.width/2);
        // 6 Update position of paddle
        paddle.position = CGPointMake(paddleX, paddle.position.y);
    }
}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    self.isPaddleTapped = NO;
}

@end
