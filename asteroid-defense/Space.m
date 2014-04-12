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

@implementation Space

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size])
    {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor blackColor];
        [self placeEarth];
    }
    return self;
}

- (CGPoint)earthPoint
{
    return CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
}

- (void)placeEarth
{
    Earth *earth = [Earth new];
    earth.position = self.earthPoint;
    [self addChild:earth];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *anyTouch = [touches anyObject];
    touchLocation = [anyTouch locationInNode:self];
    
//    fingerTracker = [SKEmitterNode alloc]
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *anyTouch = [touches anyObject];
//    CGPoint endLocation = [anyTouch locationInNode:self];
//
//    CGVector vector = CGVectorMake( endLocation.x - touchLocation.x, endLocation.y - touchLocation.y);
//    
//    Nuke *sprite = [Nuke new];
//
//    sprite.position = touchLocation;
//    [sprite setVector:vector];
//
//    [self addChild:sprite];
    
    [self launchMissileTowards:[anyTouch locationInNode:self]];
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

-(void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
}

@end
