//
//  GameScene.m
//  SteeringBehaviors
//
//  Created by Bhanu Birani on 13/12/14.
//  Copyright (c) 2014 mb. All rights reserved.
//

#import "GameScene.h"
#import <math.h>

#define kEpsilon    1.0e-6f

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define RANDOM_NUM_X arc4random() % SCREEN_WIDTH
#define RANDOM_NUM_Y arc4random() % SCREEN_HEIGHT

typedef NS_OPTIONS(uint32_t, CNPhysicsCategory)
{
    GFPhysicsCategoryWorld    = 1 << 0,  // 0001 = 1
    GFPhysicsCategoryRectangle  = 1 << 1,  // 0010 = 2
    GFPhysicsCategorySquare  = 1 << 2,  // 0100 = 4
};

@implementation GameScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        
        self.positionV2D = CGVectorMake(0, 0);
        self.velocityV2D = CGVectorMake(0, 0);
        self.steeringForce = CGVectorMake(0, 0);
        
        [self createPhysicsBodiesOnScene:self];
    }
    return self;
}

BOOL isZero(float a)
{
    return (fabs(a) < kEpsilon);
}

- (CGVector )addVector:(CGVector )vector1 withVector:(CGVector )vector2
{
    return CGVectorMake(vector1.dx + vector2.dx, vector1.dy + vector2.dy);
}

- (CGVector )subVector:(CGVector )vector1 withVector:(CGVector )vector2
{
    return CGVectorMake(vector1.dx - vector2.dx, vector1.dy - vector2.dy);
}

- (CGVector )multVector:(CGVector )vector1 withFactor:(CGFloat )factor
{
    return CGVectorMake(vector1.dx * factor, vector1.dy * factor);
}

- (CGVector )normalize:(CGVector )vector
{
    float lengthsq = vector.dx*vector.dx + vector.dy*vector.dy;

    if (isZero(lengthsq))
    {
        vector.dx = 0.0f;
        vector.dy = 0.0f;
    }
    else
    {
        float factor = 1.0f / sqrt(lengthsq);
        vector.dx *= factor;
        vector.dy *= factor;
    }
    return vector;
}

- (CGFloat)distSquare:(CGVector )vector1 withVector:(CGVector )vector2
{
    float dx = vector1.dx - vector2.dx;
    float dy = vector1.dy - vector2.dy;
    return dx * dx + dy * dy;
}

- (CGFloat )distanceBetween:(CGVector )vector1 vector:(CGVector )vector2
{
    return sqrt([self distSquare:vector1 withVector:vector2]);
}

-(void)seek:(CGVector )target {
    
    CGVector desiredVelocity = [self subVector:target withVector:CGVectorMake(head.position.x, head.position.y)];
    desiredVelocity = [self normalize:desiredVelocity];
    desiredVelocity = [self multVector:desiredVelocity withFactor:0.02f];
    [head.physicsBody applyForce:desiredVelocity];
    
    /*
    desiredVelocity = [self multVector:desiredVelocity withFactor:-0.01f];
    [head.physicsBody applyImpulse:desiredVelocity];
     */
}

- (void)arrive:(CGVector)target {
    
    CGVector playerLocation = CGVectorMake(head.position.x, head.position.y);
    
    CGVector desiredVelocity = [self subVector:target withVector:playerLocation];
    desiredVelocity = [self normalize:desiredVelocity];
    float dist = [self distanceBetween:playerLocation vector:target];
    
    if(dist < 50)
    {
        CGVector distance = [self subVector:target withVector:playerLocation];
        distance = [self multVector:distance withFactor:-0.001/10];
        [head.physicsBody applyForce:distance];
    }
    else
    {
        desiredVelocity = [self multVector:desiredVelocity withFactor:0.02f];
        [head.physicsBody applyForce:desiredVelocity];
    }
}

int myRandom() {
    return (arc4random() % 2 ? 1 : -1);
}

-(void)update:(CFTimeInterval)currentTime {
    
    [self arrive:seekLocation];
    
}

-(SKShapeNode *)makeMainBall {
    SKShapeNode *theMainBall = [[SKShapeNode alloc] init];
    CGMutablePathRef myPath = CGPathCreateMutable();
    CGPathAddArc(myPath, NULL, 0, 0, 10, 0, M_PI*2, YES);
    
    theMainBall.fillColor = [SKColor blueColor];
    theMainBall.path = myPath;
    theMainBall.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:theMainBall.frame.size.width / 2];
    
    return theMainBall;
}

-(void)createPhysicsBodiesOnScene:(SKScene*)scene {
    //Adding Rectangle
    SKSpriteNode* backBone = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size:CGSizeMake(20, 20)];
    backBone.position = CGPointMake(CGRectGetWidth(self.frame)/2.0, CGRectGetHeight(self.frame)/2.0);
    backBone.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:backBone.size];
    backBone.physicsBody.categoryBitMask = GFPhysicsCategoryRectangle;
    backBone.physicsBody.collisionBitMask = GFPhysicsCategoryWorld;
    backBone.physicsBody.dynamic = NO;
    [scene addChild:backBone];
    
    //Adding Square
    head = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(40, 40)];
    head.position = CGPointMake(backBone.position.x, backBone.position.y-40);
    head.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:1.0f];
    head.physicsBody.categoryBitMask = GFPhysicsCategorySquare;
    head.physicsBody.collisionBitMask = GFPhysicsCategoryWorld;
    [scene addChild:head];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    seekLocation = CGVectorMake(location.x, location.y);
}

@end
