//
//  GameManager.h
//  asteroid-defense
//
//  Created by Bryant Balatbat on 2014-04-13.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDidAcquireReadyNuke @"kDidAcquireReadyNuke"

@class Asteroid;

@interface GameManager : NSObject

+ (GameManager *)sharedManager;

@property (nonatomic,readonly) CGFloat earthHealth;
@property (nonatomic,readonly) CGFloat resourcesMined;
@property (nonatomic,readonly) NSUInteger nukesReady;

- (void)deployReadyNuke;
- (void)takeDamageFromAsteroid:(Asteroid *)asteroid;
- (void)takeResourcesFromAsteroid:(Asteroid *)asteroid;

@end
