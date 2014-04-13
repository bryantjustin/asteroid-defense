//
//  MyScene.m
//  asteroid-defense
//
//  Created by Adam Borzecki on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import "Space.h"
#import "Asteroid.h"
#import "Nuke.h"
#import "Earth.h"
#import "VectorUtil.h"

#import "CollisionManager.h"

@implementation Space
{
    CollisionManager *collisionManager;
}

/******************************************************************************/

#pragma mark - Utility properties

/******************************************************************************/

- (CGPoint)earthPoint
{
    return CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
}

/******************************************************************************/

#pragma mark - Initialization methods

/******************************************************************************/

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor blackColor];
        
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        
        [self prepareCollisionManager];
        [self prepareEarth];
        
        lastLaunch = 0;
        
    }
    return self;
}

/******************************************************************************/

#pragma mark - Prepare views and managers

/******************************************************************************/

- (void)prepareCollisionManager
{
    collisionManager = [CollisionManager managerWithSpace:self];
}

- (void)prepareEarth
{
    earth = [Earth new];
    earth.position = self.earthPoint;
    [self addChild:earth];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *anyTouch = [touches anyObject];
    touchLocation = [anyTouch locationInNode:self];
    
    NSString *burstPath =
    [[NSBundle mainBundle]
     pathForResource:@"FingerTracker" ofType:@"sks"];
    
    fingerTracker = [NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];
    fingerTracker.targetNode = self;
    
    fingerTracker.position = touchLocation;
    
    [self addChild:fingerTracker];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    fingerTracker.position = [[touches anyObject] locationInNode:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *anyTouch = [touches anyObject];
    
    [fingerTracker removeFromParent];
    [self launchMissileTowards:[anyTouch locationInNode:self]];
}

- (void) spawnAsteroid
{
    float angle = arc4random_uniform( 360.0 ) * M_PI / 180.0;
    
    CGPoint o = earth.position;
    CGPoint p = CGPointMake( o.x + ASTEROID_SPAWN_DISTANCE, o.y );

    CGFloat xPoint = cosf( angle ) * ( p.x - o.x ) - sinf( angle ) * ( p.y - o.y ) + o.x;
    CGFloat yPoint = sinf( angle ) * ( p.x - o.x ) + cosf( angle ) * ( p.y - o.y ) + o.y;

    CGPoint spawnPoint = CGPointMake( xPoint, yPoint );

    Asteroid *asteroid = [Asteroid new];
    asteroid.position = spawnPoint;

    asteroid.velocity = [VectorUtil normalizeVector:CGVectorMake( o.x - spawnPoint.x, o.y - spawnPoint.y ) toScale:1.];
    
    [self addChild:asteroid];
}

- (void)launchMissileTowards:(CGPoint)targetPoint
{
    CGPoint originPoint = self.earthPoint;
    CGVector vector = CGVectorMake( targetPoint.x - originPoint.x, targetPoint.y - originPoint.y);
    
    Nuke *sprite = [Nuke new];
    
    sprite.position = originPoint;
    [sprite setVector:vector];
    
    [self addChild:sprite];
}

- (void)update:(CFTimeInterval)currentTime
{
    CGPoint earthPosition = earth.position;
    
    NSMutableDictionary *calculated = [NSMutableDictionary new];
    
    for( SKNode *child in self.children )
    {
        if( child && [child isKindOfClass:Asteroid.class])
        {
            Asteroid *asteroid = (Asteroid *)child;
            CGPoint point1 = asteroid.position;
            CGVector runningVector = CGVectorMake(0.0, 0.0);
            
            for( SKNode *child2 in self.children )
            {
                if( child2 && [child2 isKindOfClass:Asteroid.class])
                {
                    Asteroid *asteroid2 = (Asteroid *)child2;
                    
                    if( asteroid == asteroid2 || asteroid.hidden == YES || asteroid2.hidden == YES || [calculated[ asteroid2 ] boolValue] == YES )
                    {
                        continue;
                    }
                    
                    CGPoint point2 = asteroid2.position;
                    
                    CGVector vector = [self getVectorBetweenPosition:point1 andPosition2:point2 andGravityForce:ASTEROIDAL_GRAVITY_FORCE];
                    runningVector = [VectorUtil addVectors:runningVector and:vector];
                }
            }
            
            runningVector = [VectorUtil addVectors:runningVector and:[self getVectorBetweenPosition:point1 andPosition2:earthPosition andGravityForce:PLANETARY_GRAVITY_FORCE]];
        
            asteroid.radialGravity = runningVector;
            
            calculated[ asteroid ] = @(YES);
        }
    }
    
    if( currentTime - lastLaunch > LAUNCH_INTERVAL )
    {
        [self spawnAsteroid];
        lastLaunch = currentTime;
    }
}

- (CGVector) getVectorBetweenPosition:(CGPoint)p1 andPosition2:(CGPoint)p2 andGravityForce:(float)gravity
{
    CGFloat distance = sqrt( pow( p1.x - p2.x, 2.0) + (pow( p1.y - p2.y, 2.0 )));
    
    CGFloat force = gravity / ( distance * distance);
    CGVector radialGravityForce = CGVectorMake((p2.x - p1.x) * force, (p2.y - p1.y) * force);
    
    return radialGravityForce;
}

@end
