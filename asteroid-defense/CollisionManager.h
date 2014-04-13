//
//  CollisionManager.h
//  asteroid-defense
//
//  Created by Bryant Balatbat on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@class Space;

@interface CollisionManager : NSObject
<
    SKPhysicsContactDelegate
>

+ (CollisionManager *)managerWithSpace:(Space *)space;

@end
