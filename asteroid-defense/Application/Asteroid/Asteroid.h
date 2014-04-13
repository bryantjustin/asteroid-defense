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
@property CGFloat mass;

@property (nonatomic) CGVector radialGravity;

- (void) prepareTrail;

- (Asteroid *)combineWithAsteroid:(Asteroid *)asteroid;

@end
