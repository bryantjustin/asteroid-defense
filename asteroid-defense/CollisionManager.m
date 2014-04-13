//
//  CollisionManager.m
//  asteroid-defense
//
//  Created by Bryant Balatbat on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import "CollisionManager.h"

#import "Asteroid.h"
#import "GameManager.h"
#import "Miner.h"
#import "Space.h"

#define PARTICLE_RESOURCE   @"nuke"
#define PARTICLE_TYPE       @"sks"
#define PARTICLES_TO_EMIT   30.f

#define MINER_FADE_DURATION 0.1f
#define ASTEROID_SCALE_DURATION 0.35f

@implementation CollisionManager
{
    __weak Space *space;
}
+ (CollisionManager *)managerWithSpace:(Space *)space;
{
    return [[self alloc] initWithSpace:space];
}

- (id)initWithSpace:(Space *)theSpace
{
    if (self = [super init])
    {
        space = theSpace;
        space.physicsWorld.contactDelegate = self;
    }
    
    return self;
}

/******************************************************************************/

#pragma mark - SKPhysicaContactDelegate

/******************************************************************************/

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    if ([self isContactBetweenNukeAndAsteroid:contact])
    {
        [self detonateNukeAtContact:contact];
    }
    else if ([self isContactBetweenEarthAndAsteroid:contact])
    {
        [self shatterAsteroidAtContact:contact];
        [self takeDamageFromAsteroidContact:contact];
    }
    else if ([self isContactBetweenMinerAndAsteroid:contact])
    {
        [self mineAsteroidAtContact:contact];
    }
    else if ([self isContactBetweenAsteroidAndAsteroid:contact])
    {
        [self combineAsteroidsAtContact:contact];
    }
    else if([self isContactBetweenDetonationAndAsteroid:contact])
    {
        [self deflectAsteroid:contact];
    }
}

/******************************************************************************/

#pragma mark - Analyse collision types

/******************************************************************************/

- (BOOL)isContactBetweenNukeAndAsteroid:(SKPhysicsContact *)contact
{
    uint32_t categoryBitMaskA = contact.bodyA.categoryBitMask;
    uint32_t categoryBitMaskB = contact.bodyB.categoryBitMask;
    
    return (categoryBitMaskA == nukeCategory && categoryBitMaskB == asteroidCategory)
    || (categoryBitMaskA == asteroidCategory && categoryBitMaskB == nukeCategory);
}

- (BOOL)isContactBetweenEarthAndAsteroid:(SKPhysicsContact *)contact
{
    uint32_t categoryBitMaskA = contact.bodyA.categoryBitMask;
    uint32_t categoryBitMaskB = contact.bodyB.categoryBitMask;
    
    return (categoryBitMaskA == earthCategory && categoryBitMaskB == asteroidCategory)
    || (categoryBitMaskA == asteroidCategory && categoryBitMaskB == earthCategory);
}

- (BOOL)isContactBetweenAsteroidAndAsteroid:(SKPhysicsContact *)contact
{
    if( !ASTEROID_COLLISIONS_COMBINE )
    {
        return NO;
    }
    
    uint32_t categoryBitMaskA = contact.bodyA.categoryBitMask;
    uint32_t categoryBitMaskB = contact.bodyB.categoryBitMask;
    
    return (categoryBitMaskA == asteroidCategory && categoryBitMaskB == asteroidCategory);
}

- (BOOL)isContactBetweenDetonationAndAsteroid:(SKPhysicsContact *)contact
{
    uint32_t categoryBitMaskA = contact.bodyA.categoryBitMask;
    uint32_t categoryBitMaskB = contact.bodyB.categoryBitMask;

    return (categoryBitMaskA == detonationCategory && categoryBitMaskB == asteroidCategory)
    || (categoryBitMaskA == asteroidCategory && categoryBitMaskB == detonationCategory);
}

- (BOOL)isContactBetweenMinerAndAsteroid:(SKPhysicsContact *)contact
{
    uint32_t categoryBitMaskA = contact.bodyA.categoryBitMask;
    uint32_t categoryBitMaskB = contact.bodyB.categoryBitMask;
    
    return (categoryBitMaskA == minerCategory && categoryBitMaskB == asteroidCategory)
    || (categoryBitMaskA == asteroidCategory && categoryBitMaskB == minerCategory);
}

/******************************************************************************/

#pragma mark - Collision reaction methods

/******************************************************************************/

- (void)detonateNukeAtContact:(SKPhysicsContact *)contact
{
    [contact.bodyA.node removeFromParent];
    [contact.bodyB.node removeFromParent];
    
    [self spawnAndSetupEmitterAt:contact.contactPoint];
}

- (void)shatterAsteroidAtContact:(SKPhysicsContact *)contact
{
    [[self asteroidForContact:contact] removeFromParent];
    
    SKEmitterNode *emitter = [self spawnEmitterAt:contact.contactPoint];
    [space addChild:emitter];
    [self
        performSelector:@selector(onEmitterComplete:)
        withObject:emitter
        afterDelay:[self lifeSpanForEmitter:emitter]
    ];
}

- (void)combineAsteroidsAtContact:(SKPhysicsContact *)contact
{
    Asteroid *a1 = (Asteroid *)contact.bodyA.node;
    Asteroid *a2 = (Asteroid *)contact.bodyB.node;
    
    Asteroid *newAsteroid = [a1 combineWithAsteroid:a2];
    newAsteroid.position = contact.contactPoint;
    NSLog( @"%@", NSStringFromCGPoint(newAsteroid.position));
    
//    [a1 removeFromParent];
    [a2 removeFromParent];
}

- (void) deflectAsteroid:(SKPhysicsContact *)contact
{
    Asteroid *asteroid = [self asteroidForContact:contact];
    
    SKNode *originNode;
    
    if( asteroid == contact.bodyA.node )
    {
        originNode = contact.bodyB.node;
    }
    else
    {
        originNode = contact.bodyA.node;
    }
    
    CGPoint o = originNode.position;
    CGPoint a = asteroid.position;
    
    CGVector vector = [VectorUtil normalizeVector: CGVectorMake( ( a.x - o.x ) * 1, ( a.y - o.y ) * 1) toScale:15.0];
    
    [asteroid.physicsBody applyImpulse:vector];
}
    
- (void)mineAsteroidAtContact:(SKPhysicsContact *)contact
{
    __weak Miner* miner = [self minerForContact:contact];
    
    SKAction *action = [SKAction fadeOutWithDuration:MINER_FADE_DURATION];
    [miner
        runAction:action
        completion:^(void)
        {
            [miner removeFromParent];
            
        }
    ];
    
    __weak Asteroid* asteroid = [self asteroidForContact:contact];
    if (!asteroid.isBeingMined)
    {
        asteroid.isBeingMined = YES;
        action = [SKAction
            scaleTo:0.
            duration:ASTEROID_SCALE_DURATION * asteroid.radius / ASTEROID_MAX_RADIUS
        ];
        
        [asteroid
            runAction:action
         
            completion:^(void)
            {
                [GameManager.sharedManager takeResourcesFromAsteroid:asteroid];
                [space updateResourcesMined];
                [space.earth updateHealth];
                [asteroid removeFromParent];
            }
        ];
    }
}

- (void)takeDamageFromAsteroidContact:(SKPhysicsContact *)contact
{
    [GameManager.sharedManager takeDamageFromAsteroid:[self asteroidForContact:contact]];
    [[self earthForContact:contact] updateHealth];
    if (GameManager.sharedManager.earthHealth <= 0)
    {
        [space initiateSelfDestruct];
    }
}

/******************************************************************************/

#pragma mark - Utility methods

/******************************************************************************/

- (Earth *)earthForContact:(SKPhysicsContact *)contact
{
    Earth *earth = nil;
    if ([contact.bodyA.node isKindOfClass:Earth.class])
    {
        earth = (Earth *)contact.bodyA.node;
    }
    else if([contact.bodyB.node isKindOfClass:Earth.class])
    {
        earth = (Earth *)contact.bodyB.node;
    }
    return earth;
}

- (Asteroid *)asteroidForContact:(SKPhysicsContact *)contact
{
    Asteroid *asteroid = nil;
    if ([contact.bodyA.node isKindOfClass:Asteroid.class])
    {
        asteroid = (Asteroid *)contact.bodyA.node;
    }
    else if([contact.bodyB.node isKindOfClass:Asteroid.class])
    {
        asteroid = (Asteroid *)contact.bodyB.node;
    }
    return asteroid;
}

- (Miner *)minerForContact:(SKPhysicsContact *)contact
{
    Miner *miner = nil;
    if ([contact.bodyA.node isKindOfClass:Miner.class])
    {
        miner = (Miner *)contact.bodyA.node;
    }
    else if([contact.bodyB.node isKindOfClass:Miner.class])
    {
        miner = (Miner *)contact.bodyB.node;
    }
    return miner;
}

- (void)onEmitterComplete:(SKEmitterNode *)emitter
{
    [emitter removeFromParent];
}

- (SKEmitterNode *)spawnEmitterAt:(CGPoint)position
{
    SKEmitterNode *emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:self.particlePath];
    emitter.position = position;
    emitter.numParticlesToEmit = PARTICLES_TO_EMIT;
    return emitter;
}

- (void) spawnAndSetupEmitterAt:(CGPoint)position
{
    SKEmitterNode *emitter = [self spawnEmitterAt:position];
    [space addChild:emitter];
    [self
     performSelector:@selector(onEmitterComplete:)
     withObject:emitter
     afterDelay:[self lifeSpanForEmitter:emitter]
     ];
}

- (NSString *)particlePath
{
    return [[NSBundle mainBundle]
        pathForResource:PARTICLE_RESOURCE
        ofType:PARTICLE_TYPE
    ];
}

- (NSTimeInterval)lifeSpanForEmitter:(SKEmitterNode *)emitter
{
    return emitter.numParticlesToEmit / emitter.particleBirthRate +
    emitter.particleLifetime + emitter.particleLifetimeRange / 2.;
}

@end