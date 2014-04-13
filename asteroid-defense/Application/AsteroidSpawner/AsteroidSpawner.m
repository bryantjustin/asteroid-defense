//
//  AsteroidSpawner.m
//  asteroid-defense
//
//  Created by Adam Borzecki on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import "AsteroidSpawner.h"
#import "Asteroid.h"

@implementation AsteroidSpawner

+ (Asteroid *) spawn
{
    float angle = arc4random_uniform( 360.0 ) * M_PI / 180.0;
    
//    CGPoint o = earth.position;
//    CGPoint p = CGPointMake( o.x + ASTEROID_SPAWN_DISTANCE, o.y );
//    
//    CGFloat xPoint = cosf( angle ) * ( p.x - o.x ) - sinf( angle ) * ( p.y - o.y ) + o.x;
//    CGFloat yPoint = sinf( angle ) * ( p.x - o.x ) + cosf( angle ) * ( p.y - o.y ) + o.y;
//    
//    CGPoint spawnPoint = CGPointMake( xPoint, yPoint );
//    
//    Asteroid *asteroid = [Asteroid new];
//    asteroid.position = spawnPoint;
//    
//    asteroid.velocity = [VectorUtil normalizeVector:CGVectorMake( o.x - spawnPoint.x, o.y - spawnPoint.y ) toScale:1.];
//    
//    [self addChild:asteroid];
    
    return nil;
}

@end
