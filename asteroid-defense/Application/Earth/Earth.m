//
//  Earth.m
//  asteroid-defense
//
//  Created by Adam Borzecki on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import "Earth.h"
#import "Game.h"

@implementation Earth

- (id) init
{
    if( self = [super init])
    {
        SKSpriteNode *asteroid = [SKSpriteNode spriteNodeWithImageNamed:@"Asteroid"];
        
        asteroid.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:15.0];
        asteroid.physicsBody.categoryBitMask = planetCategory;
        asteroid.physicsBody.dynamic = NO;
        asteroid.physicsBody.mass = 300.0;
        
        [self addChild:asteroid];
    }
    
    return self;
}

@end
