//
//  Player.m
//  SteeringBehaviors
//
//  Created by Bhanu Birani on 25/12/14.
//  Copyright (c) 2014 mb. All rights reserved.
//

#import "Player.h"

@implementation Player

+ (Player*) playerObject {
    // Create a new critter, and give it a name
    Player* obj = [Player spriteNodeWithColor:[SKColor whiteColor] size:CGSizeMake(30, 30)];
    obj.name = @"GamePlayer";
    return obj;
}

- (void) seek:(CGPoint )target deltaTime:(float)deltaTime {
    
    // Work out the direction to this position
    GLKVector2 myPosition = GLKVector2Make(self.position.x, self.position.y);
    GLKVector2 targetPosition = GLKVector2Make(target.x, target.y);
    
    GLKVector2 offset = GLKVector2Subtract(targetPosition, myPosition);
    
    // Reduce this vector to be the same length as our movement speed
    offset = GLKVector2Normalize(offset);
    offset = GLKVector2MultiplyScalar(offset, 10);
    
    [self.physicsBody applyForce:CGVectorMake(offset.x, offset.y)];
}

- (void) arrive:(CGPoint )target deltaTime:(float)deltaTime {
    
    // Work out the direction to this position
    GLKVector2 myPosition = GLKVector2Make(self.position.x, self.position.y);
    GLKVector2 targetPosition = GLKVector2Make(target.x, target.y);
    
    GLKVector2 offset = GLKVector2Subtract(targetPosition, myPosition);
    
    // Reduce this vector to be the same length as our movement speed
    offset = GLKVector2Normalize(offset);
    offset = GLKVector2MultiplyScalar(offset, 5);
    
    // Add this to our current position
    CGPoint newPosition = self.position;
    newPosition.x += offset.x;
    newPosition.y += offset.y;
    
    self.position = newPosition;
}

- (void) flee:(CGPoint )target deltaTime:(float)deltaTime {
    
    // Work out the direction to this position
    GLKVector2 myPosition = GLKVector2Make(self.position.x, self.position.y);
    GLKVector2 targetPosition = GLKVector2Make(target.x, target.y);
    
    GLKVector2 offset = GLKVector2Subtract(targetPosition, myPosition);
    
    // Reduce this vector to be the same length as our movement speed
    offset = GLKVector2Normalize(offset);
    offset = GLKVector2MultiplyScalar(offset, -10);
    
    [self.physicsBody applyForce:CGVectorMake(offset.x, offset.y)];
}

- (void) evade:(CGPoint )target deltaTime:(float)deltaTime {
    
    GLKVector2 myPosition = GLKVector2Make(self.position.x, self.position.y);
    GLKVector2 targetPosition = GLKVector2Make(target.x, target.y);
    
    GLKVector2 offset = GLKVector2Subtract(targetPosition, myPosition);
    
    // Reduce this vector to be the same length as our movement speed
    offset = GLKVector2Normalize(offset);
    
    // Note the minus sign - we're multiplying by the inverse of our movement speed,
    // which means we're moving away from it
    offset = GLKVector2MultiplyScalar(offset, -5);
    
    // Add this to our current position
    CGPoint newPosition = self.position;
    newPosition.x += offset.x;
    newPosition.y += offset.y;
    
    self.position = newPosition;
}

int myRandom() {
    return (arc4random() % 2 ? 1 : -1);
}

- (void)wanderWithDeltaTime:(float)deltaTime
{
    int boxWidth = 20;
    
    CGRect targetRect = CGRectMake(self.target.x - boxWidth, self.target.y - boxWidth, boxWidth*2, boxWidth*2);
    if (!CGRectContainsPoint(targetRect, self.position)) {
        
        [self seek:self.target deltaTime:deltaTime];
        
    } else {
        int offsetX = self.scene.size.width;
        int offsetY = self.scene.size.height;
        
        self.target = CGPointMake(arc4random() % offsetX, arc4random() % offsetY);
    }
}

- (void) update:(float)deltaTime {
    
    if (self.behaviourType == Arrive) {
        int boxWidth = 20;
        
        CGRect targetRect = CGRectMake(self.target.x - boxWidth, self.target.y - boxWidth, boxWidth*2, boxWidth*2);
        if (!CGRectContainsPoint(targetRect, self.position)) {
            [self arrive:self.target deltaTime:deltaTime];
        }
    }
    
    if (self.behaviourType == Seek) {
        
        [self seek:self.target deltaTime:deltaTime];
    }
    
    if (self.behaviourType == Flee) {
        
        [self flee:self.target deltaTime:deltaTime];
    }
    
    if (self.behaviourType == Evade) {
        int boxWidth = 100;
        CGRect targetRect = CGRectMake(self.target.x - boxWidth, self.target.y - boxWidth, boxWidth*2, boxWidth*2);
        if (CGRectContainsPoint(targetRect, self.position)) {
            
            [self evade:self.target deltaTime:deltaTime];
        }
    }
    
    if (self.behaviourType == Wander) {
        
        [self wanderWithDeltaTime:deltaTime];
    }
}

@end
