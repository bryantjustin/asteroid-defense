//
//  Game.h
//  asteroid-defense
//
//  Created by Adam Borzecki on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

static const uint32_t nukeCategory      =  0x1 << 0;
static const uint32_t asteroidCategory  =  0x1 << 1;
static const uint32_t planetCategory    =  0x1 << 2;
static const uint32_t mineCategory      =  0x1 << 3;

#define EARTH_RADIUS 60.f
#define MAX_ASTEROID_MULTIPLIER 10.0 / 6000.0

#define PLANETARY_GRAVITY_FORCE 4000.0f
#define ASTEROIDAL_GRAVITY_FORCE 400.0f
#define ASTEROID_SPAWN_DISTANCE 640.0f
#define LAUNCH_INTERVAL 3.0f

#define EARTH_CENTER CGPointMake( 512.0, 384.0 )