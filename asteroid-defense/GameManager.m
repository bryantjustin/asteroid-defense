//
//  GameManager.m
//  asteroid-defense
//
//  Created by Bryant Balatbat on 2014-04-13.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import "GameManager.h"

#import "Asteroid.h"
#import "GameConstants.h"

@implementation GameManager

/******************************************************************************/

#pragma mark - Singleton reference.

/******************************************************************************/

+ (GameManager *)sharedManager
{
    static GameManager *instance = nil;
    static dispatch_once_t predicate = 0;
    
    dispatch_once(
        &predicate,
        ^(void)
        {
            instance = [GameManager new];
        }
    );
    
    return instance;
}

/******************************************************************************/

#pragma mark - Initialization method

/******************************************************************************/

- (id)init
{
    if (self = [super init])
    {
        earthHealth = BASE_EARTH_HEALTH;
        nukesReady = BASE_NUKES_READY;
    }
    
    return self;
}

/******************************************************************************/

#pragma mark - Synthesized properties

/******************************************************************************/

@synthesize nukesReady;
@synthesize resourcesMined;
@synthesize earthHealth;

/******************************************************************************/

#pragma mark - Game calculations

/******************************************************************************/

- (void)deployReadyNuke
{
    nukesReady = MAX(0, nukesReady - 1);
}

- (void)takeDamageFromAsteroid:(Asteroid *)asteroid
{
    earthHealth -= [self radiusFactorForAsteroid:asteroid] * BASE_ASTEROID_DAMAGE ;
}

- (void)takeResourcesFromAsteroid:(Asteroid *)asteroid
{
    int resourcesMinedFromAsteroid = [self radiusFactorForAsteroid:asteroid] * BASE_ASTEROID_RESOURCES;
    
    earthHealth =  MIN( BASE_EARTH_HEALTH, earthHealth + resourcesMinedFromAsteroid * PERCENTAGE_OF_MINED_RESOURCES_TO_HEALTH );
    
    resourcesMined += resourcesMinedFromAsteroid * PERCENTAGE_OF_MINED_RESOURCES_TO_NUKE;
    if (resourcesMined > REQUIRED_RESOURCES_FOR_NUKE)
    {
        nukesReady++;
        resourcesMined -= REQUIRED_RESOURCES_FOR_NUKE;
        
        [NSNotificationCenter.defaultCenter
            postNotificationName:kDidAcquireReadyNuke
            object:self
        ];
    }
}

/******************************************************************************/

#pragma mark - Game utilities

/******************************************************************************/

- (CGFloat)radiusFactorForAsteroid:(Asteroid *)asteroid
{
    return asteroid.radius / ASTEROID_MAX_RADIUS;
}
@end
