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

@end

@implementation FSMyScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        /* Setup your scene here */
        
        self.backgroundColor = [UIColor colorWithRed:135.0/255.0
                                               green:206.0/255.0
                                                blue:235.0/255.0
                                               alpha:1.0];
        
        [self addSpaceShip];
    }
    return self;
}

- (void)addSpaceShip
{
    self.spaceShipSprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship.png"];
    
    self.spaceShipSprite.position = CGPointMake(self.spaceShipSprite.size.width,
                                                self.frame.size.height/2);
    
    [self addChild:self.spaceShipSprite];
}

- (void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
}

@end
