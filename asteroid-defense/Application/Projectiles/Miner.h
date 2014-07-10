//
//  Miner.h
//  asteroid-defense
//
//  Created by Bryant Balatbat on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Projectile.h"

@interface Miner : SKSpriteNode
<
    Projectile
>

@property (nonatomic) CGVector vector;

@end
