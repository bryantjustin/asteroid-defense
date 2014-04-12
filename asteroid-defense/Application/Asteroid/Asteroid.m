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
    if( self = [super initWithImageNamed:@"Asteroid"])
    {
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:15.0];
        self.physicsBody.categoryBitMask = asteroidCategory;
        self.physicsBody.dynamic = YES;
        self.physicsBody.mass = 1.0;
        self.physicsBody.linearDamping = 0.0;
    }
    
    return self;
}

- (void) setVelocity:(CGVector)velocity
{
    self.physicsBody.velocity = velocity;
}

- (void) setRadialGravity:(CGVector)radialGravity
{
    [self.physicsBody applyForce:radialGravity];
}

- (void) prepareTrail
{
    NSString *burstPath = [[NSBundle mainBundle] pathForResource:@"AsteroidPath" ofType:@"sks"];
    SKEmitterNode *trail = [NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];
    trail.targetNode = self.parent;
    [self addChild:trail];
}

@end
