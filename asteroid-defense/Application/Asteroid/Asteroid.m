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
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.radius];
        self.physicsBody.categoryBitMask = asteroidCategory;
        if( ASTEROID_COLLISIONS_COMBINE )
        {
            self.physicsBody.collisionBitMask = asteroidCategory;
            self.physicsBody.contactTestBitMask = asteroidCategory;
        }
        self.physicsBody.dynamic = YES;
        self.physicsBody.mass = 1.f + ( self.radius - 5.0 ) / 5.0;
        self.physicsBody.linearDamping = 0.0;
    }
    
    return self;
}

- (id) initWithMass:(CGFloat)mass andRadius:(float)radius
{
    if( self = [super initWithTexture:[Asteroid texture:radius]])
    {
        self.radius = radius;
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.radius];
        self.physicsBody.categoryBitMask = asteroidCategory;
        self.physicsBody.collisionBitMask = asteroidCategory;
        self.physicsBody.contactTestBitMask = asteroidCategory;
        self.physicsBody.dynamic = YES;
        self.physicsBody.mass = mass;
        self.physicsBody.linearDamping = 0.0;
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

- (CGFloat)mass
{
    return self.physicsBody.mass;
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
    Asteroid *newAsteroid = [[Asteroid alloc] initWithMass:self.mass + asteroid.mass andRadius:self.radius + asteroid.radius ];
    newAsteroid.velocity = [VectorUtil addVectors:self.velocity and:asteroid.velocity];
    
    return newAsteroid;
}

@end
