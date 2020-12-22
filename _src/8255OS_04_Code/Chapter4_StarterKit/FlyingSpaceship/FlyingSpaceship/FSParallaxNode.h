//
//  FSParallaxNode.h
//  FlyingSpaceship
//
//  Created by Rahul on 9/20/14.
//  Copyright (c) 2014 RahulBorawar. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface FSParallaxNode : SKNode

- (id)initWithBackgrounds:(NSArray *)imageFiles
                     size:(CGSize)size
                    speed:(CGFloat)velocity;

- (void)updateForDeltaTime:(NSTimeInterval)diffTime;

@end
