//
//  Asteroid.m
//  asteroid-defense
//
//  Created by Adam Borzecki on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import "Asteroid.h"

@implementation Asteroid

- (id) init
{
    float radius = arc4random_uniform( 5.0 ) + 5.0;
    
    if( self = [super initWithTexture:[Asteroid texture:radius]])
    {
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
        self.physicsBody.categoryBitMask = asteroidCategory;
        self.physicsBody.dynamic = YES;
        self.physicsBody.mass = 1.0 + ( radius - 5.0 ) / 5.0;
        self.physicsBody.linearDamping = 0.0;
    }
    
    return self;
}

- (void) setVelocity:(CGVector)velocity
{
    self.physicsBody.velocity = velocity;
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

@end
