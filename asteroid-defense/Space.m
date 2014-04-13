//
//  MyScene.m
//  asteroid-defense
//
//  Created by Adam Borzecki on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import "Space.h"
#import "Asteroid.h"
#import "Game.h"
#import "Nuke.h"
#import "Miner.h"
#import "Earth.h"
#import "VectorUtil.h"

#import "CollisionManager.h"

#define kRADIAL_GRAVITY_FORCE 1000.0f
#define ASTEROID_SPAWN_DISTANCE 1500.0f
#define LAUNCH_INTERVAL 3.0f

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
    
    [self
        launchProjectile:Miner.class
        towards:[anyTouch locationInNode:self]
    ];
//    [self
//        launchProjectile:Nuke.class
//        towards:[anyTouch locationInNode:self]
//    ];
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
    
    asteroid.velocity = [VectorUtil
        normalizeVector:CGVectorMake( o.x - spawnPoint.x, o.y - spawnPoint.y )
        toScale:50.
    ];
    
    [self addChild:asteroid];
}

- (void)launchProjectile:(Class)class
    towards:(CGPoint)targetPoint
{
    CGPoint originPoint = self.earthPoint;
    CGVector vector = CGVectorMake( targetPoint.x - originPoint.x, targetPoint.y - originPoint.y);
    
    SKSpriteNode<Projectile> *sprite = [class new];
    
    sprite.position = originPoint;
    [sprite setVector:vector];
    
    [self addChild:sprite];
}


- (void)update:(CFTimeInterval)currentTime
{
    CGPoint earthPosition = earth.position;
    
    for( SKNode *child in self.children )
    {
        if( child && [child isKindOfClass:Asteroid.class])
        {
            Asteroid *asteroid = (Asteroid *)child;
            
            CGPoint position = child.position;
            CGFloat distance = sqrt( pow( position.x - earthPosition.x, 2.0) + (pow( position.y - earthPosition.y, 2.0 )));
            
            if( distance < 100 ) continue;
            
            CGFloat force = kRADIAL_GRAVITY_FORCE / ( distance * distance);
            CGVector radialGravityForce = CGVectorMake((earthPosition.x - position.x) * force, (earthPosition.y - position.y) * force);
            
            asteroid.radialGravity = radialGravityForce;
        }
    }
    
    if( currentTime - lastLaunch > LAUNCH_INTERVAL )
    {
        [self spawnAsteroid];
        lastLaunch = currentTime;
    }
}

@end
