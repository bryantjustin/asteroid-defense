//
//  Asteroid.m
//  asteroid-defense
//
//  Created by Adam Borzecki on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import "Asteroid.h"
#import "VectorUtil.h"

@implementation Asteroid

@synthesize isBeingMined;

- (id) init
{
    float __radius = arc4random_uniform( ASTEROID_MIN_RADIUS ) + ASTEROID_MIN_RADIUS;
    
    if( self = [super initWithTexture:[Asteroid texture:__radius]])
    {
        self.radius = __radius;
        float mass = 1.0 + ( self.radius - 5.0 ) / 5.0;
        self.physicsBody = [Asteroid getPhyicsBodyWithRadius:__radius andMass:mass];
        self.mass = self.physicsBody.mass;
    }
    
    return self;
}

- (id) initAsWorldKiller
{
    if( self = [super initWithTexture:[Asteroid texture:ASTEROID_WORLD_KILLER_RADIUS]])
    {
        self.radius = ASTEROID_WORLD_KILLER_RADIUS;
        float mass = 1.0 + ( self.radius - 5.0 ) / 5.0;
        self.physicsBody = [Asteroid getPhyicsBodyWithRadius:ASTEROID_WORLD_KILLER_RADIUS andMass:mass];
        self.physicsBody.categoryBitMask = asteroidCategory | worldKillerCategory;
        self.mass = self.physicsBody.mass;
    }
    
    return self;
}

- (void) setVelocity:(CGVector)velocity
{
    self.physicsBody.velocity = velocity;
}
- (CGVector)velocity
{
    return self.physicsBody.velocity;
}

- (void) setRadialGravity:(CGVector)radialGravity
{
    [self.physicsBody applyForce:radialGravity];
}

- (void) prepareTrail
{
    NSString *burstPath = [[NSBundle mainBundle] pathForResource:@"AsteroidPath" ofType:@"sks"];
    SKEmitterNode *trail = [NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];
    trail.targetNode = self.parent;
    [self addChild:trail];
}

+ (SKTexture *)texture: (float)radius
{
    
    UIGraphicsBeginImageContext(CGSizeMake(radius * 2., radius * 2.));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [SKColor.whiteColor set];
    CGContextSetLineWidth(context, 2.0);
    
    CGRect rect = CGRectMake(
        0,
        0,
        radius * 2,
        radius * 2
    );
    
    CGContextStrokeEllipseInRect(context, CGRectInset(rect, 2, 2));
    
    UIImage *textureImage = UIGraphicsGetImageFromCurrentImageContext();
    SKTexture *texture = [SKTexture textureWithImage:textureImage];
    UIGraphicsEndImageContext();
    
    return texture;
}

- (Asteroid *)combineWithAsteroid:(Asteroid *)asteroid
{
    self.radius += asteroid.radius;
    self.texture = [Asteroid texture:self.radius];
    self.mass += asteroid.mass;
    self.velocity = [VectorUtil addVectors:self.velocity and:asteroid.velocity];
    self.physicsBody = nil;
    self.physicsBody = [Asteroid getPhyicsBodyWithRadius:self.radius andMass:self.mass];
    
    return self;
}

+ (SKPhysicsBody *)getPhyicsBodyWithRadius:(float)radius andMass:(float)mass
{
    SKPhysicsBody *physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
    physicsBody.categoryBitMask = asteroidCategory;
    if( ASTEROID_COLLISIONS_COMBINE )
    {
        physicsBody.collisionBitMask = asteroidCategory | detonationCategory;
        physicsBody.contactTestBitMask = asteroidCategory | detonationCategory;
    }
    else
    {
        physicsBody.collisionBitMask = asteroidCategory;
        physicsBody.contactTestBitMask = detonationCategory;
    }
    
    physicsBody.dynamic = YES;
    physicsBody.mass = mass;
    physicsBody.linearDamping = 0.0;
    
    return physicsBody;
}

@end
