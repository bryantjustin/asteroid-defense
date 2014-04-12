//
//  Asteroid.m
//  asteroid-defense
//
//  Created by Adam Borzecki on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import "Asteroid.h"
#import "Game.h"

@implementation Asteroid

- (id) init
{
    if( self = [super init])
    {
        internal = [SKSpriteNode spriteNodeWithImageNamed:@"Asteroid"];
        
        internal.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:15.0];
        internal.physicsBody.categoryBitMask = asteroidCategory;
        internal.physicsBody.dynamic = YES;
        internal.physicsBody.mass = 1.0;
        
        [self addChild:internal];
    }
    
    return self;
}

- (void) setVelocity:(CGVector)velocity
{
    internal.physicsBody.velocity = velocity;
}

- (void) setRadialGravity:(CGVector)radialGravity
{
    [internal.physicsBody applyForce:radialGravity];
}

@end
