//
//  Game.h
//  asteroid-defense
//
//  Created by Adam Borzecki on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import <Foundation/Foundation.h>

static const uint32_t nukeCategory      =  0x1 << 0;
static const uint32_t asteroidCategory  =  0x1 << 1;
static const uint32_t planetCategory    =  0x1 << 2;
static const uint32_t mineCategory      =  0x1 << 3;

@interface Game : NSObject

@end
