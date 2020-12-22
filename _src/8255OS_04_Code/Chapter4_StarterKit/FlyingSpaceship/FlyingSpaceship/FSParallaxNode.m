//
//  FSParallaxNode.m
//  FlyingSpaceship
//
//  Created by Rahul on 9/20/14.
//  Copyright (c) 2014 RahulBorawar. All rights reserved.
//

#import "FSParallaxNode.h"

@interface FSParallaxNode()

@property (nonatomic, strong)  NSMutableArray*  backgrounds;
@property (nonatomic, assign)  NSInteger        noOfBackgrounds;

@property (nonatomic, assign) CGFloat           velocity;

@end

static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}

@implementation FSParallaxNode

- (id)initWithBackgrounds:(NSArray *)imageFiles
                     size:(CGSize)size
                    speed:(CGFloat)velocity
{
    if (self = [super init])
    {
        self.velocity = velocity;

        self.noOfBackgrounds = [imageFiles count];
        self.backgrounds =
        [NSMutableArray arrayWithCapacity:self.noOfBackgrounds];
        
        [imageFiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
        {
            SKSpriteNode *backgroundNode =
            [SKSpriteNode spriteNodeWithImageNamed:obj];
            
            backgroundNode.size = size;
            backgroundNode.anchorPoint = CGPointZero;
            backgroundNode.position = CGPointMake(size.width * idx, 0.0);
            backgroundNode.name = @"background";
            [self.backgrounds addObject:backgroundNode];
            [self addChild:backgroundNode];
        }];
    }
    return self;
}

- (void)updateForDeltaTime:(NSTimeInterval)diffTime
{
    CGPoint bgVelocity = CGPointMake(self.velocity, 0.0);
    
    CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity,diffTime);
    
    self.position = CGPointAdd(self.position, amtToMove);
    
    SKNode *backgroundScreen = self.parent;
    
    [self.backgrounds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        SKSpriteNode *bg = (SKSpriteNode *)obj;
        
        CGPoint bgScreenPos = [self convertPoint:bg.position
                                          toNode:backgroundScreen];
        
        if (bgScreenPos.x <= -bg.size.width)
        {
            bg.position =
            CGPointMake(bg.position.x + (bg.size.width * self.noOfBackgrounds),
                        bg.position.y);
        }
    }];
}

@end
