//
//  Nuke.m
//  asteroid-defense
//
//  Created by Bryant Balatbat on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import "Nuke.h"
#import "VectorUtil.h"

#define LEVEL_1_SCALE 75.f

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
    self.physicsBody.mass = 1.f;
    self.physicsBody.linearDamping = 0.f;
    self.physicsBody.collisionBitMask = asteroidCategory;
    self.physicsBody.contactTestBitMask = asteroidCategory;
}

@synthesize vector;
- (void)setVector:(CGVector)value;
{
    vector = value;
    self.physicsBody.velocity = [VectorUtil
        normalizeVector:vector
        toScale:LEVEL_1_SCALE
    ];
    self.zRotation = atan2(vector.dy,vector.dx);
}

@end
