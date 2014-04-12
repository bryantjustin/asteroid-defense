//
//  MyScene.h
//  asteroid-defense
//

//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Space : SKScene
{
    CGPoint touchLocation;
    
    SKEmitterNode *fingerTracker;
}

@end
