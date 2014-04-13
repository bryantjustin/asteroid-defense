//
//  Asteroid.h
//  asteroid-defense
//
//  Created by Adam Borzecki on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Asteroid : SKSpriteNode
{
}

@property float radius;
@property (nonatomic) CGVector velocity;
@property (nonatomic) CGFloat mass;
@property (nonatomic) CGVector radialGravity;
@property (nonatomic) BOOL isBeingMined;

- (id) initWithMass:(CGFloat)mass andRadius:(float)radius;

- (void) prepareTrail;

- (Asteroid *)combineWithAsteroid:(Asteroid *)asteroid;

@end
