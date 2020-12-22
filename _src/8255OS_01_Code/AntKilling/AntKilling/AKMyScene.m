//
//  AKMyScene.m
//  AntKilling
//
//  Created by Bhanu Birani on 21/07/14.
//  Copyright (c) 2014 YourCompanyName. All rights reserved.
//

#import "AKMyScene.h"

@interface AKMyScene ()

@property (nonatomic) SKSpriteNode *ant;

@end

@implementation AKMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        self.ant = [SKSpriteNode spriteNodeWithImageNamed:@"ant.jpg"];
        self.ant.position = CGPointMake(100, 100);
        [self addChild:self.ant];
        
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:positionInScene];
    if (touchedNode == self.ant) {
        SKAction *sequence = [SKAction sequence:@[[SKAction rotateByAngle:degreeToRadian(-3.0f) duration:0.2],
                                                  [SKAction rotateByAngle:0.0 duration:0.1],
                                                  [SKAction rotateByAngle:degreeToRadian(3.0f) duration:0.2]]];
        
        [touchedNode runAction:[SKAction repeatActionForever:sequence]];
    } else {
        [self.ant removeAllActions];
    }
}

float degreeToRadian(float degree) {
	return degree / 180.0f * M_PI;
}

@end
