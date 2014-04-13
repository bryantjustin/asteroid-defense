//
//  NukeExplosion.m
//  asteroid-defense
//
//  Created by Adam Borzecki on 2014-04-13.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import "NukeExplosion.h"

#define PARTICLES_TO_EMIT   50.
#define PARTICLE_RESOURCE   @"nuke"
#define PARTICLE_TYPE       @"sks"

@implementation NukeExplosion

- (id) init
{
    if (self = [super initWithTexture:[NukeExplosion texture:40]])
    {
        [self preparePhysics];
        
        SKEmitterNode *emitter = [self spawnEmitterAt:CGPointMake(0, 0)];
        [self addChild:emitter];
        [self
         performSelector:@selector(onEmitterComplete:)
         withObject:emitter
         afterDelay:[self lifeSpanForEmitter:emitter]
         ];
    }
    
    return self;
}

- (SKEmitterNode *)spawnEmitterAt:(CGPoint)position
{
    SKEmitterNode *emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:self.particlePath];
    emitter.position = position;
    emitter.numParticlesToEmit = PARTICLES_TO_EMIT;
    return emitter;
}

- (void)preparePhysics
{
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:40.0];
    self.physicsBody.categoryBitMask = detonationCategory;
    self.physicsBody.dynamic = NO;
}

+ (SKTexture *)texture: (float)radius
{
    
    UIGraphicsBeginImageContext(CGSizeMake(radius * 2., radius * 2.));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [SKColor.redColor set];
    CGContextSetLineWidth(context, 2.0);
    CGContextSetAlpha( context, 0.0 );
    
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



- (NSString *)particlePath
{
    return [[NSBundle mainBundle]
            pathForResource:PARTICLE_RESOURCE
            ofType:PARTICLE_TYPE
            ];
}

- (NSTimeInterval)lifeSpanForEmitter:(SKEmitterNode *)emitter
{
    return emitter.numParticlesToEmit / emitter.particleBirthRate +
    emitter.particleLifetime + emitter.particleLifetimeRange / 2.;
}

- (void)onEmitterComplete:(SKEmitterNode *)emitter
{
    [self removeFromParent];
}

@end
