//
//  Earth.m
//  asteroid-defense
//
//  Created by Bryant Balatbat on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import "Earth.h"

@implementation Earth
{
    NSSet *nodes;
    
    BOOL shouldTryMinerLaunch;
    BOOL shouldTryNukeLaunch;
}

#define MINER_LAUNCHER_NAME @"miner-launcher"
#define MINER_LAUNCHER_NODE_X -25
#define MINER_LAUNCHER_NODE_Y 10

#define NUKE_LAUNCHER_NAME @"nuke-launcher"
#define NUKE_LAUNCHER_NODE_X 25
#define NUKE_LAUNCHER_NODE_Y 10

#define LAUNCHER_NORMAL( $launcher )    [NSString stringWithFormat: @"%@%@", $launcher, @"-normal.png"]
#define LAUNCHER_HIGHLIGHT( $launcher ) [NSString stringWithFormat: @"%@%@", $launcher, @"-highlight.png"]

/******************************************************************************/

#pragma mark - Static methods

/******************************************************************************/

+ (SKTexture *)texture
{
    UIGraphicsBeginImageContext(CGSizeMake(EARTH_RADIUS * 2., EARTH_RADIUS * 2.));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [SKColor.whiteColor setFill];
    CGContextFillEllipseInRect(
        context,
        CGRectMake(
            0,
            0,
            EARTH_RADIUS * 2,
            EARTH_RADIUS * 2
        )
    );
    
    UIImage *textureImage = UIGraphicsGetImageFromCurrentImageContext();
    SKTexture *texture = [SKTexture textureWithImage:textureImage];
    UIGraphicsEndImageContext();
    
    return texture;
}

/******************************************************************************/

#pragma mark - Inherited methods

/******************************************************************************/

- (id) init
{
    if (self = [super initWithTexture:Earth.texture])
    {
        [self setUserInteractionEnabled:YES];
        [self preparePhysics];
        [self prepareLaunchers];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches
    withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKSpriteNode *node = (SKSpriteNode *)[self nodeAtPoint:location];

    shouldTryMinerLaunch = [self isNodeMinerLauncher:node];
    shouldTryNukeLaunch = [self isNodeNukeLauncher:node];
    
    if (shouldTryMinerLaunch
        || shouldTryNukeLaunch)
    {
        [node setTexture:[SKTexture textureWithImageNamed:LAUNCHER_HIGHLIGHT(node.name)]];
    }
}

- (void)touchesEnded:(NSSet *)touches
    withEvent:(UIEvent *)event
{
    for (SKSpriteNode *node in nodes)
    {
        [node setTexture:[SKTexture textureWithImageNamed:LAUNCHER_NORMAL(node.name)]];
    }
    
    [self
        handleTouchesEnded:touches
    ];
}


/******************************************************************************/

#pragma mark - Prepares physics and buttons

/******************************************************************************/

- (void)preparePhysics
{
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:EARTH_RADIUS];
    self.physicsBody.categoryBitMask = earthCategory;
    self.physicsBody.dynamic = NO;
    self.physicsBody.mass = 300.0;
    self.physicsBody.collisionBitMask = asteroidCategory;
    self.physicsBody.contactTestBitMask = asteroidCategory;
}

- (void)prepareLaunchers
{
    NSMutableSet *mutableNodeSet = [NSMutableSet set];
    
    SKSpriteNode *node = self.minerLauncher;
    [self addChild:node];
    [mutableNodeSet addObject:node];
    
    node = self.nukeLauncher;
    [self addChild:node];
    [mutableNodeSet addObject:node];
    
    nodes = [NSSet setWithSet:mutableNodeSet];
}

/******************************************************************************/

#pragma mark - Launcher methods

/******************************************************************************/

- (SKSpriteNode *)minerLauncher
{
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:LAUNCHER_NORMAL(MINER_LAUNCHER_NAME)];
    node.position = CGPointMake(MINER_LAUNCHER_NODE_X, MINER_LAUNCHER_NODE_Y);
    node.name = MINER_LAUNCHER_NAME;
    node.zPosition = 1.f;
    return node;
}

- (BOOL)isNodeMinerLauncher:(SKSpriteNode *)node
{
    return [node.name isEqualToString:MINER_LAUNCHER_NAME];
}

- (SKSpriteNode *)nukeLauncher
{
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:LAUNCHER_NORMAL(NUKE_LAUNCHER_NAME)];
    node.position = CGPointMake(NUKE_LAUNCHER_NODE_X, NUKE_LAUNCHER_NODE_Y);
    node.name = NUKE_LAUNCHER_NAME;
    node.zPosition = 1.f;
    return node;
}

- (BOOL)isNodeNukeLauncher:(SKSpriteNode *)node
{
    return [node.name isEqualToString:NUKE_LAUNCHER_NAME];
}

/******************************************************************************/

#pragma mark - Launcher state methods

/******************************************************************************/

- (void)handleTouchesEnded:(NSSet *)touches
{
    if (shouldTryMinerLaunch)
    {
        [self.delegate
            earth:self
            didTryToLaunchMinerWithTouches:touches
        ];
    }
    
    if (shouldTryNukeLaunch)
    {
        [self.delegate
            earth:self
            didTryToLaunchNukeWithTouches:touches
        ];
    }
    
    shouldTryMinerLaunch = NO;
    shouldTryNukeLaunch = NO;
}

@end
