//
//  FSMyScene.m
//  FlyingSpaceship
//
//  Created by Rahul on 9/13/14.
//  Copyright (c) 2014 RahulBorawar. All rights reserved.
//

#import "FSMyScene.h"

@interface FSMyScene()

@property (nonatomic, strong) SKSpriteNode*     spaceShipSprite;

@property (nonatomic, strong) SKAction*         moveUpAction;
@property (nonatomic, strong) SKAction*         moveDownAction;

@property (nonatomic, assign) NSTimeInterval    lastUpdatedTime;
@property (nonatomic, assign) NSTimeInterval    diffTime;

@property (nonatomic, assign) NSTimeInterval    lastCoinAdded;

@end

static const float SPACE_BG_ONE_TIME_MOVE_DISTANCE = 30.0;
static const float SPACE_BG_ONE_TIME_MOVE_TIME = 0.2;
static const float SPACE_BG_VELOCITY = 100.0;

static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}

@implementation FSMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        [self initalizingScrollingBackground];
        
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

- (void)initalizingScrollingBackground
{
    for (int index = 0; index < 2; index++)
    {
        SKSpriteNode *spaceBGNode =
        [SKSpriteNode spriteNodeWithImageNamed:@"SpaceBackground.png"];
        {
            spaceBGNode.position =
            CGPointMake(index * spaceBGNode.size.width, 0);
            spaceBGNode.anchorPoint = CGPointZero;
            spaceBGNode.name = @"SpaceBG";
            
            [self addChild:spaceBGNode];
        }
    }
}

- (void)moveSpaceBackground
{
    [self enumerateChildNodesWithName:@"SpaceBG"
                           usingBlock: ^(SKNode *node, BOOL *stop)
     {
         SKSpriteNode * spaceBGNode = (SKSpriteNode *) node;
         
         CGPoint bgVelocity = CGPointMake(-SPACE_BG_VELOCITY, 0);
         
         CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity,self.diffTime);
         
         spaceBGNode.position = CGPointAdd(spaceBGNode.position, amtToMove);
         
         //Checks if Background node is completely scrolled of the screen, if yes then put it at the end of the other node
         
         if (spaceBGNode.position.x <= -spaceBGNode.size.width)
         {
             spaceBGNode.position =
             CGPointMake(spaceBGNode.position.x + spaceBGNode.size.width*2,
                         spaceBGNode.position.y);
         }
     }];
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
    
    [self moveSpaceBackground];
}

@end