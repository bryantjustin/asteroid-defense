//
//  MyScene.h
//  asteroid-defense
//

//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Earth.h"

@interface Space : SKScene
<
    SKPhysicsContactDelegate
>
{
    CGPoint touchLocation;
    Earth *earth;
    SKEmitterNode *fingerTracker;
    NSTimeInterval lastLaunch;
}

@end
