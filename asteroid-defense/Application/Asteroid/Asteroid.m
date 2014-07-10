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
        
        healthPoints = arc4random_uniform( WORLD_KILLER_HIT_POINTS_MAX - WORLD_KILLER_HIT_POINTS_MIN ) + WORLD_KILLER_HIT_POINTS_MIN;
        
        health = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
        health.text = [NSString stringWithFormat:@"%d", healthPoints];
        health.fontSize = 12.0;
        health.fontColor = SKColor.whiteColor;
        health.position = CGPointMake( 0.0, -5.0 );
        
        [self addChild:health];
    }
    
    return self;
}

- (void) setVelocity:(CGVector)velocity
{
    self.physicsBody.velocity = velocity;
    
    SKAction *action = [SKAction rotateByAngle:atan2(velocity.dy,velocity.dx) duration:10];
    [self runAction:[SKAction repeatActionForever:action]];
}
- (CGVector)velocity
{
    return self.physicsBody.velocity;
}

- (void) setRadialGravity:(CGVector)radialGravity
{
    [self.physicsBody applyForce:radialGravity];
}

- (void) damage
{
    self.damagePoints++;
    health.text = [NSString stringWithFormat:@"%d", healthPoints - self.damagePoints];
    if( self.damagePoints == healthPoints )
    {
        [self removeFromParent];
    }
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
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1.0, 1.5, 1.0, 1.0);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    
    int points = 16;
    float degreesPerPoint = 360.0/(float)points;
    float currentAngle = 0.0;
    float minRadius = radius - 5.0;
    float maxRadius = radius;
    CGPoint firstPoint;
    
    for( int i = 0; i < points; i++ )
    {
        float angleRandom = degreesPerPoint;//[self randomFloatBetween:0.0 and:degreesPerPoint];
        float angle = currentAngle + angleRandom;
        float r = [self randomFloatBetween:minRadius and:maxRadius];
        CGPoint point = [VectorUtil rotatePoint:CGPointMake(radius + r, radius  ) aboutPoint:CGPointMake( radius , radius  ) byAngle:angle * M_PI / 180.0];
        if( i == 0 )
        {
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), point.x, point.y);
            firstPoint = point;
        }
        else
        {
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), point.x, point.y);
        }
        
        currentAngle = angle;
    }
    
    CGContextAddLineToPoint( UIGraphicsGetCurrentContext(), firstPoint.x, firstPoint.y );
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());

    UIImage *textureImage = UIGraphicsGetImageFromCurrentImageContext();
    SKTexture *texture = [SKTexture textureWithImage:textureImage];
    UIGraphicsEndImageContext();
    
    return texture;
}

+ (float)randomFloatBetween:(float)smallNumber and:(float)bigNumber
{
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
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
