//
//  Earth.m
//  asteroid-defense
//
//  Created by Bryant Balatbat on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import "Earth.h"

@implementation Earth

- (id) init
{
    if (self = [super initWithTexture:Earth.texture])
    {
        [self preparePhysics];
    }
    
    return self;
}

- (void)preparePhysics
{
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:EARTH_RADIUS];
    self.physicsBody.categoryBitMask = planetCategory;
    self.physicsBody.dynamic = NO;
    self.physicsBody.mass = 300.0;
}

+ (SKTexture *)texture
{
    UIGraphicsBeginImageContext(CGSizeMake(EARTH_RADIUS * 2., EARTH_RADIUS * 2.));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [SKColor.whiteColor setFill];
    CGContextFillEllipseInRect(context, CGRectMake(
       0,
       0,
       EARTH_RADIUS * 2,
       EARTH_RADIUS * 2
    ));
    
    UIImage *textureImage = UIGraphicsGetImageFromCurrentImageContext();
    SKTexture *texture = [SKTexture textureWithImage:textureImage];
    UIGraphicsEndImageContext();
    
    return texture;
}

@end
