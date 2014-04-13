//
//  AsteroidSpawner.h
//  asteroid-defense
//
//  Created by Adam Borzecki on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Asteroid.h"

static NSTimeInterval lastSpawn;

@interface AsteroidSpawner : NSObject

+ (Asteroid *) spawn:(NSTimeInterval)currentTime;

@end
