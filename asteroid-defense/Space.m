//
//  MyScene.m
//  asteroid-defense
//
//  Created by Adam Borzecki on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import "Space.h"
#import "Asteroid.h"
#import "Earth.h"

@implementation Space

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size])
    {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor blackColor];

        Earth *earth = [Earth new];
        earth.position = CGPointMake( size.width / 2.0, size.height / 2.0 );
        [self addChild:earth];
        
    }
    return self;
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
    CGPoint endLocation = [anyTouch locationInNode:self];
    
    CGVector vector = CGVectorMake( endLocation.x - touchLocation.x, endLocation.y - touchLocation.y);
    Asteroid *sprite = [Asteroid new];

    sprite.position = touchLocation;
    sprite.velocity = vector;

    [self addChild:sprite];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
