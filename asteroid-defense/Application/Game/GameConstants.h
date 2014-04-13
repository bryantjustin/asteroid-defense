//
//  Game.h
//  asteroid-defense
//
//  Created by Adam Borzecki on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

static const uint32_t noCategory        =  0x1 << 0;
static const uint32_t nukeCategory      =  0x1 << 1;
static const uint32_t asteroidCategory  =  0x1 << 2;
static const uint32_t earthCategory     =  0x1 << 3;
static const uint32_t minerCategory     =  0x1 << 4;

#define EARTH_RADIUS 40.f
#define MAX_ASTEROID_MULTIPLIER 10.0 / 6000.0

#define PLANETARY_GRAVITY_FORCE 4000.0f
#define ASTEROIDAL_GRAVITY_FORCE 400.0f
#define ASTEROID_SPAWN_DISTANCE 640.0f
#define ASTEROID_MIN_RADIUS 10.f
#define ASTEROID_MAX_RADIUS ASTEROID_MIN_RADIUS * 2
#define LAUNCH_INTERVAL 3.5f

#define EARTH_CENTER CGPointMake( 512.0, 384.0 )

#define ASTEROID_COLLISIONS_COMBINE NO

#define BASE_EARTH_HEALTH 100.f
#define BASE_ASTEROID_DAMAGE 15.
#define BASE_NUKE_DAMAGE 10.

#define BASE_NUKES_READY 2
#define BASE_ASTEROID_RESOURCES 15.
#define REQUIRED_RESOURCES_FOR_NUKE 100

#define PERCENTAGE_OF_MINED_RESOURCES_TO_NUKE 0.6
#define PERCENTAGE_OF_MINED_RESOURCES_TO_HEALTH 0.4