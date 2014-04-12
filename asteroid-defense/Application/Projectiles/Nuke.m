//
//  Nuke.m
//  asteroid-defense
//
//  Created by Bryant Balatbat on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import "Nuke.h"
#import "Game.h"

@implementation Nuke

- (id) init
{
    if (self = [super initWithImageNamed:@"nuke.png"])
    {
        [self preparePhysics];
    }
    
    return self;
}

- (void)preparePhysics
{
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:12.0];
    self.physicsBody.categoryBitMask = nukeCategory;
    self.physicsBody.dynamic = YES;
    self.physicsBody.allowsRotation = YES;
    self.physicsBody.mass = 5.0;
    self.physicsBody.collisionBitMask = asteroidCategory;
    self.physicsBody.contactTestBitMask = asteroidCategory;
    self.physicsBody.friction = 0.0;
}

- (void)setVector:(CGVector)vector
{
    self.physicsBody.velocity = vector;
    self.zRotation = atan2(vector.dy,vector.dx);
}

- (void) setRadialGravity:(CGVector)radialGravity
{
    [self.physicsBody applyForce:radialGravity];
}

@end
