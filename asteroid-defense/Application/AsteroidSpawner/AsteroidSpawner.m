//
//  AsteroidSpawner.m
//  asteroid-defense
//
//  Created by Adam Borzecki on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import "AsteroidSpawner.h"
#import "VectorUtil.h"

@implementation AsteroidSpawner

+ (Asteroid *) spawn:(NSTimeInterval)currentTime
{
    if( currentTime - lastSpawn > LAUNCH_INTERVAL )
    {
        lastSpawn = currentTime;
        return [AsteroidSpawner generateAsteroid];
    }
    
    return nil;
}

+ (Asteroid *) generateAsteroid
{
    float angle = arc4random_uniform( 360.0 ) * M_PI / 180.0;
    
    BOOL isWorldKiller = [self isWorldKiller];
    
    CGPoint o = EARTH_CENTER;
    CGPoint p = CGPointMake( o.x, ASTEROID_SPAWN_DISTANCE);
    
    CGPoint spawnPoint = [self rotatePoint:p aboutPoint:o byAngle:angle];
    
    Asteroid *asteroid = isWorldKiller ? [[Asteroid alloc] initAsWorldKiller] : [Asteroid new];
    asteroid.position = spawnPoint;
    
    CGPoint targetPoint;
    if( isWorldKiller )
    {
        targetPoint = o;
        [NSNotificationCenter.defaultCenter postNotificationName:@"WorldKiller" object:nil];
    }
    else
    {
        BOOL up = arc4random() * 100 > 50;
        float distance = arc4random_uniform(ASTEROID_SPAWN_DISTANCE - EARTH_RADIUS) + EARTH_RADIUS;
        distance *= ( up ) ? 1 : -1;
        
        targetPoint = [self rotatePoint:CGPointMake( o.x, o.y + distance) aboutPoint:o byAngle: angle + ( M_PI_2 * ( up ? 1 : -1 )) ];
    }
    
    asteroid.velocity = [VectorUtil normalizeVector:CGVectorMake( targetPoint.x - spawnPoint.x, targetPoint.y - spawnPoint.y ) toScale: isWorldKiller ? 25. : 12.];

    return asteroid;
}

+ (CGPoint) rotatePoint:(CGPoint)point aboutPoint:(CGPoint)origin byAngle:(float)angleInRadians
{
    CGFloat xPoint = cosf( angleInRadians ) * ( point.x - origin.x ) - sinf( angleInRadians ) * ( point.y - origin.y ) + origin.x;
    CGFloat yPoint = sinf( angleInRadians ) * ( point.x - origin.x ) + cosf( angleInRadians ) * ( point.y - origin.y ) + origin.y;
    
    return CGPointMake( xPoint, yPoint );
}

+ (BOOL) isWorldKiller
{
    int num = arc4random_uniform( 100 );
    return num > 90;
}

@end
