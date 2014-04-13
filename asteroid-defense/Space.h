//
//  MyScene.h
//  asteroid-defense
//

//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Earth.h"


typedef enum
{
    ProjectileTypeMiner,
    ProjectileTypeNuke
} ProjectileType;

@interface Space : SKScene
<
    EarthDelegate
>
{
    CGPoint touchLocation;
    SKEmitterNode *fingerTracker;
    NSTimeInterval lastLaunch;
}

- (void)updateResourcesMined;

@property (nonatomic,strong) Earth *earth;

@end
