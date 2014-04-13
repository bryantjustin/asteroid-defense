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

@class Space;

@protocol SpaceDelegate <NSObject>

- (void)spaceDidRequestToTryAgain:(Space *)self;

@end

@interface Space : SKScene
<
    EarthDelegate
>
{
    CGPoint touchLocation;
    SKEmitterNode *fingerTracker;
    NSMutableDictionary *calculated;
}

- (void)spawnNukeExplostionAt:(CGPoint)point;
- (void)updateResourcesMined;
- (void)initiateSelfDestruct;

@property (nonatomic,strong) Earth *earth;
@property (nonatomic,weak) id<SpaceDelegate> delegate;

@end
