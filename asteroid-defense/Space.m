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

#define kRADIAL_GRAVITY_FORCE 2000.0f

@implementation Space

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size])
    {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor blackColor];

        earth = [Earth new];
        earth.position = CGPointMake( size.width / 2.0, size.height / 2.0 );
        [self addChild:earth];
        
    }
    return self;
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
    CGPoint endLocation = [anyTouch locationInNode:self];
    
    CGVector vector = CGVectorMake( endLocation.x - touchLocation.x, endLocation.y - touchLocation.y);
    Asteroid *sprite = [Asteroid new];

    sprite.position = touchLocation;
    sprite.velocity = vector;

    [self addChild:sprite];
    
    [fingerTracker removeFromParent];
    fingerTracker = nil;
}

- (CGVector) distanceBetween:(CGVector)v1 and:(CGVector)v2
{
    return CGVectorMake( v2.dx - v1.dx, v2.dy - v1.dy );
}

- (float) lengthSquared:(CGVector)input
{
    return input.dx * input.dx + input.dy * input.dy;
}

- (float) length:(CGVector)input
{
    return sqrtf([self lengthSquared:input]);
}

- (float) normalizeVector:(CGVector) input
{
    float length = [self length:input];
    if (length < FLT_EPSILON)
    {
        return 0.0f;
    }
    float invLength = 1.0f / length;
    input.dx *= invLength;
    input.dy *= invLength;
    
    return length;
}

-(void)update:(CFTimeInterval)currentTime
{
    CGVector earthPos = CGVectorMake( earth.position.x, earth.position.y );
    
    for( SKSpriteNode *child in self.children )
    {
        if( child && [child isKindOfClass:Asteroid.class])
        {
            Asteroid *asteroid = (Asteroid *)child;
            
            CGVector position = CGVectorMake( child.position.x, child.position.y );
            CGVector distance = [self distanceBetween:earthPos and:position];
            CGFloat force = kRADIAL_GRAVITY_FORCE / [self lengthSquared:distance];
            [self normalizeVector:distance];
            CGVector radialGravityForce = CGVectorMake( distance.dx * force, distance.dy * force);
            
            asteroid.radialGravity = radialGravityForce;
        }
    }
}

@end
