//
//  Nuke.h
//  asteroid-defense
//
//  Created by Bryant Balatbat on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Projectile.h"

@interface Nuke : SKSpriteNode
<
    Projectile
>

@property (nonatomic) CGVector vector;
@property (nonatomic) CGVector radialGravity;

@end
