//
//  FSMyScene.m
//  FlyingSpaceship
//
//  Created by Rahul on 9/13/14.
//  Copyright (c) 2014 RahulBorawar. All rights reserved.
//

#import "FSMyScene.h"

#import "FSParallaxNode.h"

@interface FSMyScene()

@property (nonatomic, strong) SKSpriteNode*     spaceShipSprite;

@property (nonatomic, strong) SKAction*         moveUpAction;
@property (nonatomic, strong) SKAction*         moveDownAction;

@property (nonatomic, assign) NSTimeInterval    lastUpdatedTime;
@property (nonatomic, assign) NSTimeInterval    diffTime;

@property (nonatomic, assign) NSTimeInterval    lastCoinAdded;

@property (nonatomic, strong) FSParallaxNode*   spaceBlueSkyParallaxNode;
@property (nonatomic, strong) FSParallaxNode*   spaceWhiteMistParallaxNode;

@end

static const float SPACE_BG_ONE_TIME_MOVE_DISTANCE = 30.0;
static const float SPACE_BG_ONE_TIME_MOVE_TIME = 0.2;
static const float SPACE_BLUE_SKY_BG_VELOCITY = 20.0;
static const float SPACE_WHITE_MIST_BG_VELOCITY = 100.0;

@implementation FSMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        [self addParallaxNodes];
        
        [self addSpaceShip];
    }
    return self;
}

- (void)addSpaceShip
{
    SKTextureAtlas *textureAtlas = [SKTextureAtlas atlasNamed:@"FSGame"];

    SKTexture* spaceShipTexture = [textureAtlas textureNamed:@"Spaceship.png"];

    self.spaceShipSprite = [SKSpriteNode spriteNodeWithTexture:spaceShipTexture];
    
    self.spaceShipSprite.position = CGPointMake(self.spaceShipSprite.size.width,
                                                self.frame.size.height/2);
    
    [self addChild:self.spaceShipSprite];
    
    self.moveUpAction = [SKAction moveByX:0
                                        y:SPACE_BG_ONE_TIME_MOVE_DISTANCE
                                 duration:SPACE_BG_ONE_TIME_MOVE_TIME];

    self.moveDownAction = [SKAction moveByX:0
                                        y:-SPACE_BG_ONE_TIME_MOVE_DISTANCE
                                 duration:SPACE_BG_ONE_TIME_MOVE_TIME];
}

- (void)addCoin
{
    SKTextureAtlas *textureAtlas = [SKTextureAtlas atlasNamed:@"FSGame"];
    SKTexture* coinInitialTexture = [textureAtlas textureNamed:@"Coin1.png"];
    
    SKSpriteNode* coinSprite = [SKSpriteNode spriteNodeWithTexture:coinInitialTexture];
    
    CGFloat coinInitialPositionX = self.frame.size.width + coinSprite.size.width/2;
    CGFloat coinInitialPositionY = arc4random() % 320;

    CGPoint coinInitialPosition =
    CGPointMake(coinInitialPositionX, coinInitialPositionY);
    
    coinSprite.position = coinInitialPosition;
    
    coinSprite.name = @"Coin";
    [self addChild:coinSprite];
    
    SKTexture* coin2Texture = [textureAtlas textureNamed:@"Coin2.png"];
    SKTexture* coin3Texture = [textureAtlas textureNamed:@"Coin3.png"];
    SKTexture* coin4Texture = [textureAtlas textureNamed:@"Coin4.png"];
    SKTexture* coin5Texture = [textureAtlas textureNamed:@"Coin5.png"];
    SKTexture* coin6Texture = [textureAtlas textureNamed:@"Coin6.png"];

    NSArray *coinAnimationTextures =
    @[coinInitialTexture,coin2Texture,coin3Texture,coin4Texture,
      coin5Texture,coin6Texture];
    
    SKAction *rotateAction =
    [SKAction animateWithTextures:coinAnimationTextures
                     timePerFrame:0.2];
    SKAction *coinRepeatForeverAnimation = [SKAction repeatActionForever:rotateAction];
    [coinSprite runAction:coinRepeatForeverAnimation];

    CGFloat coinFinalPositionX = -coinSprite.size.width/2;
    CGFloat coinFinalPositionY = coinInitialPositionY;

    CGPoint coinFinalPosition =
    CGPointMake(coinFinalPositionX, coinFinalPositionY);
    
    SKAction *coinMoveAnimation = [SKAction moveTo:coinFinalPosition
                                          duration:5.0];
    [coinSprite runAction:coinMoveAnimation];
}

- (void)addParallaxNodes
{
    NSArray *blueSkyParallaxBackgroundNames =
    @[@"SpaceBackground.png", @"SpaceBackground.png",];
    
    self.spaceBlueSkyParallaxNode =
    [[FSParallaxNode alloc] initWithBackgrounds:blueSkyParallaxBackgroundNames
                                           size:self.frame.size
                                          speed:-SPACE_BLUE_SKY_BG_VELOCITY];
    self.spaceBlueSkyParallaxNode.position =
    CGPointMake(0, 0);
    
    [self addChild:self.spaceBlueSkyParallaxNode];

    NSArray *mistParallaxBackgroundNames =
    @[@"SpaceWhiteMist.png", @"SpaceWhiteMist.png",];
    
    self.spaceWhiteMistParallaxNode =
    [[FSParallaxNode alloc] initWithBackgrounds:mistParallaxBackgroundNames
                                           size:self.frame.size
                                          speed:-SPACE_WHITE_MIST_BG_VELOCITY];
    self.spaceWhiteMistParallaxNode.position =
    CGPointMake(0, 0);
    
    [self addChild:self.spaceWhiteMistParallaxNode];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint touchLocation = [touch locationInNode:self.scene];
    
    CGPoint spaceShipPosition = self.spaceShipSprite.position;

    CGFloat minYLimitToMove = SPACE_BG_ONE_TIME_MOVE_DISTANCE;
    CGFloat maxYLimitToMove =
    self.frame.size.height - SPACE_BG_ONE_TIME_MOVE_DISTANCE;

    if(touchLocation.y > spaceShipPosition.y)
    {
        if (spaceShipPosition.y < maxYLimitToMove)
        {
            [self.spaceShipSprite runAction:self.moveUpAction];
        }
    }
    else
    {
        if (spaceShipPosition.y > minYLimitToMove)
        {
            [self.spaceShipSprite runAction:self.moveDownAction];
        }
    }
}

- (void)detectSpaceShipCollisionWithCoins
{
    [self enumerateChildNodesWithName:@"Coin"
                           usingBlock: ^(SKNode *node, BOOL *stop)
     {
         if (CGRectIntersectsRect(self.spaceShipSprite.frame, node.frame))
         {
             [self spaceShipCollidedWithCoin:node];
         }
     }];
}

- (void)spaceShipCollidedWithCoin:(SKNode*)coinNode
{
    [self runSpaceshipCollectingAnimation];
    
    [self runCollectedAnimationForCoin:coinNode];
}

- (void)runSpaceshipCollectingAnimation
{
    SKAction* scaleUp = [SKAction scaleTo:1.4
                                 duration:0.2];

    SKAction* scaleDown = [SKAction scaleTo:1.0
                                   duration:0.2];

    NSArray* scaleSequenceAnimations =
    [NSArray arrayWithObjects:scaleUp, scaleDown, nil];
    
    SKAction* spaceShipCollectingAnimation = [SKAction sequence:scaleSequenceAnimations];
    
    [self.spaceShipSprite runAction:spaceShipCollectingAnimation];
}

- (void)runCollectedAnimationForCoin:(SKNode*)coinNode
{
    SKAction* coinFadeOutAnimation =
    [SKAction fadeOutWithDuration:0.4];
    
    SKAction* scaleDownAnimation =
    [SKAction scaleTo:0.2 duration:0.4];
    
    NSArray* coinAnimations =
    [NSArray arrayWithObjects:coinFadeOutAnimation, scaleDownAnimation, nil];
    
    SKAction* coinGroupAnimation = [SKAction group:coinAnimations];
    
    SKAction* coinAnimationFinishedCallBack =
    [SKAction customActionWithDuration:0.0
                           actionBlock:^(SKNode *node,CGFloat elapsedTime)
     {
         [node removeFromParent];
     }];
    
    NSArray* coinAnimationsSequence =
    [NSArray arrayWithObjects:coinGroupAnimation, coinAnimationFinishedCallBack, nil];
    
    SKAction* coinSequenceAnimation =
    [SKAction sequence:coinAnimationsSequence];
    
    [coinNode runAction:coinSequenceAnimation];
}

- (void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */

    if (self.lastUpdatedTime)
    {
        self.diffTime = currentTime - self.lastUpdatedTime;
    }
    else
    {
        self.diffTime = 0;
    }
    
    self.lastUpdatedTime = currentTime;
    
    if( currentTime - self.lastCoinAdded > 1)
    {
        self.lastCoinAdded = currentTime + 1;
        
        [self addCoin];
    }
    
    [self detectSpaceShipCollisionWithCoins];
    
    if (self.spaceBlueSkyParallaxNode)
    {
        [self.spaceBlueSkyParallaxNode updateForDeltaTime:self.diffTime];
    }
    
    if (self.spaceWhiteMistParallaxNode)
    {
        [self.spaceWhiteMistParallaxNode updateForDeltaTime:self.diffTime];
    }
}

@end