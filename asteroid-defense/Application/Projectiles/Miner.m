//
//  Miner.m
//  asteroid-defense
//
//  Created by Bryant Balatbat on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import "Miner.h"
#import "GameConstants.h"
#import "VectorUtil.h"

#define LEVEL_1_SCALE 100.f

@implementation Miner

- (id) init
{
    if (self = [super initWithImageNamed:@"miner.png"])
    {
        [self preparePhysics];
    }
    
    return self;
}

- (void)preparePhysics
{
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:12.0];
    self.physicsBody.categoryBitMask = minerCategory;
    self.physicsBody.dynamic = YES;
    self.physicsBody.mass = 0.0001f;
    self.physicsBody.restitution = 1.f;
    self.physicsBody.linearDamping = 0.f;
    self.physicsBody.collisionBitMask = noCategory;
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
    
    SKAction *action = [SKAction rotateByAngle:atan2(vector.dy,vector.dx) duration:1];
    [self runAction:[SKAction repeatActionForever:action]];
}

@end
