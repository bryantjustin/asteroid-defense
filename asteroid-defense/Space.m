//
//  MyScene.m
//  asteroid-defense
//
//  Created by Adam Borzecki on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import "Space.h"

#import "Asteroid.h"
#import "GameManager.h"
#import "Nuke.h"
#import "NukeExplosion.h"
#import "Miner.h"
#import "Earth.h"
#import "AsteroidSpawner.h"

#import "CollisionManager.h"

#define MINER_LAUNCHER_NAME @"miner-launcher"
#define MINER_LAUNCHER_NODE_X 40.f
#define MINER_LAUNCHER_NODE_Y 275.f

#define NUKE_LAUNCHER_NAME @"nuke-launcher"
#define NUKE_LAUNCHER_NODE_X 95.f
#define NUKE_LAUNCHER_NODE_Y 275.f

#define LAUNCHER_NORMAL( $launcher )    [NSString stringWithFormat: @"%@%@", $launcher, @"-normal.png"]
#define LAUNCHER_HIGHLIGHT( $launcher ) [NSString stringWithFormat: @"%@%@", $launcher, @"-highlight.png"]

@implementation Space
{
    CollisionManager *collisionManager;
    
    SKLabelNode *nukeCountLabel;
    SKLabelNode *resourcesMinedLabel;
    SKLabelNode *timer;
    SKLabelNode *worldKillerWarning;
    
    int time;
    NSTimeInterval lastTime;
    SKLabelNode *earthWasLostLabel;
    SKLabelNode *tapToTryAgain;
    
    NSSet *nodes;
    ProjectileType projectileType;
    
    BOOL markedForSelfDestruct;
}

@synthesize earth;

/******************************************************************************/

#pragma mark - Utility properties

/******************************************************************************/

- (CGPoint)earthPoint
{
    return CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
}

/******************************************************************************/

#pragma mark - Initialization methods

/******************************************************************************/

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor blackColor];
        
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        
        [self prepareCollisionManager];
        [self prepareEarth];
        [self prepareLauncherControls];
        [self prepareLabels];
    }
    return self;
}

/******************************************************************************/

#pragma mark - Deconstructor

/******************************************************************************/

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter
        removeObserver:self
        name:kDidAcquireReadyNuke
        object:GameManager.sharedManager
    ];
    [NSNotificationCenter.defaultCenter
        removeObserver:self
        name:@"WorldKiller"
        object:nil
    ];
}
/******************************************************************************/

#pragma mark - Prepare views and managers

/******************************************************************************/

- (void)prepareCollisionManager
{
    collisionManager = [CollisionManager managerWithSpace:self];
}

- (void)prepareEarth
{
    earth = [Earth new];
    earth.position = self.earthPoint;
    earth.delegate = self;
    [self addChild:earth];
}

- (void)prepareLauncherControls
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

- (void)prepareLabels
{
    resourcesMinedLabel = [self
        labelForString:@"0/100"
        andPosition:CGPointMake(40, 235)
        withFontSize:12
    ];
    [self addChild:resourcesMinedLabel];
     
    nukeCountLabel = [self
        labelForString:@(GameManager.sharedManager.nukesReady).stringValue
        andPosition:CGPointMake(95, 235)
        withFontSize:12
    ];
    [self addChild:nukeCountLabel];
    
    timer = [self
        labelForString:@"TIME: 00000"
        andPosition:CGPointMake(20,770)
        withFontSize:18
    ];
    [timer setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
    [self addChild:timer];
    
    worldKillerWarning = [self
        labelForString:@"WORLD KILLER APPROACHING!"
        andPosition:CGPointMake(385,580)
        withFontSize:18
    ];
    [worldKillerWarning setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    [self addChild:worldKillerWarning];
    worldKillerWarning.alpha = 0;
    
    [NSNotificationCenter.defaultCenter
        addObserver:self
        selector:@selector(onAcquiredReadyNuke)
        name:kDidAcquireReadyNuke
        object:GameManager.sharedManager
    ];

    [NSNotificationCenter.defaultCenter
     addObserver:self
     selector:@selector(onWorldKillerSpawn)
     name:@"WorldKiller"
     object:nil
     ];
    
    earthWasLostLabel = [self
        labelForString:@"EARTH WAS LOST!"
        andPosition:CGPointMake(385, 680)
        withFontSize:48.
    ];
    [earthWasLostLabel setAlpha:0.];
    [self addChild:earthWasLostLabel];
    
    tapToTryAgain = [self labelForString:@"TAP TO TRY AGAIN."
        andPosition:CGPointMake(385, 630)
        withFontSize:48.
    ];
    [tapToTryAgain setAlpha:0.];
    [self addChild:tapToTryAgain];
}

- (void)onAcquiredReadyNuke
{
    [self updateNukesReady];
}

- (void) onWorldKillerSpawn
{
    [worldKillerWarning runAction:[SKAction fadeAlphaTo:1 duration:1.0] completion:^{
        [worldKillerWarning runAction:[SKAction fadeAlphaTo:0.0 duration:1.0]];
    }];
}

- (void)initiateSelfDestruct
{
    SKAction *action = [SKAction
        fadeAlphaTo:1.f
        duration:0.35
    ];
    
    [earthWasLostLabel runAction:action];
    [tapToTryAgain
        runAction:action
        completion:^(void)
        {
            markedForSelfDestruct = YES;
        }
    ];
}

/******************************************************************************/

#pragma mark - Touch methods

/******************************************************************************/

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *anyTouch = [touches anyObject];
    touchLocation = [anyTouch locationInNode:self];
    
    NSString *burstPath =
    [[NSBundle mainBundle]
     pathForResource:@"FingerTracker" ofType:@"sks"];
    
    fingerTracker = [NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];
    fingerTracker.targetNode = self;
    
    fingerTracker.position = touchLocation;
    
    [self addChild:fingerTracker];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    fingerTracker.position = [[touches anyObject] locationInNode:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (markedForSelfDestruct)
    {
        [self.delegate spaceDidRequestToTryAgain:self];
        return;
    }
    
    [fingerTracker removeFromParent];
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKSpriteNode *endingNode = (SKSpriteNode *)[self nodeAtPoint:location];
    
    if ([nodes containsObject:endingNode])
    {
        for (SKSpriteNode *node in nodes)
        {
            if (endingNode == node)
            {
                [node setTexture:[SKTexture textureWithImageNamed:LAUNCHER_HIGHLIGHT(node.name)]];
                
                if ([self isNodeMinerLauncher:node])
                {
                    projectileType = ProjectileTypeMiner;
                }
                else if([self isNodeNukeLauncher:node])
                {
                    projectileType = ProjectileTypeNuke;
                }
            }
            else
            {
                [node setTexture:[SKTexture textureWithImageNamed:LAUNCHER_NORMAL(node.name)]];
            }
        }
    }
}

/******************************************************************************/

#pragma mark - Launcher methods

/******************************************************************************/

- (SKSpriteNode *)minerLauncher
{
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:LAUNCHER_HIGHLIGHT(MINER_LAUNCHER_NAME)];
    node.position = CGPointMake(MINER_LAUNCHER_NODE_X, MINER_LAUNCHER_NODE_Y);
    node.name = MINER_LAUNCHER_NAME;
    return node;
}

- (SKSpriteNode *)nukeLauncher
{
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:LAUNCHER_NORMAL(NUKE_LAUNCHER_NAME)];
    node.position = CGPointMake(NUKE_LAUNCHER_NODE_X, NUKE_LAUNCHER_NODE_Y);
    node.name = NUKE_LAUNCHER_NAME;
    return node;
}

- (BOOL)isNodeMinerLauncher:(SKSpriteNode *)node
{
    return [node.name isEqualToString:MINER_LAUNCHER_NAME];
}

- (BOOL)isNodeNukeLauncher:(SKSpriteNode *)node
{
    return [node.name isEqualToString:NUKE_LAUNCHER_NAME];
}


/******************************************************************************/

#pragma mark - Label methods

/******************************************************************************/

- (SKLabelNode *)labelForString:(NSString *)string
    andPosition:(CGPoint)position
    withFontSize:(CGFloat)fontSize
{
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
    label.text = string;
    label.fontSize = fontSize;
    label.fontColor = SKColor.whiteColor;
    label.position = position;
    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    
    return label;
}

- (void)updateResourcesMined
{
    [resourcesMinedLabel setText:[NSString stringWithFormat: @"%d/%d",@(GameManager.sharedManager.resourcesMined).integerValue, REQUIRED_RESOURCES_FOR_NUKE]];
}

- (void)updateNukesReady
{
    [nukeCountLabel setText:@(GameManager.sharedManager.nukesReady).stringValue];
}

/******************************************************************************/

#pragma mark - EarthDelegate methods

/******************************************************************************/

- (void)earth:(Earth *)theEarth
    didRequestToFireProjectileWithTouches:(NSSet *)touches
{
    switch (projectileType)
    {
        case ProjectileTypeMiner:
            [self
                launchProjectile:Miner.class
                towards:[touches.anyObject locationInNode:self]
            ];
            break;
        
        case ProjectileTypeNuke:
            if (GameManager.sharedManager.nukesReady > 0)
            {
                [GameManager.sharedManager deployReadyNuke];
                [self updateNukesReady];
                [self
                    launchProjectile:Nuke.class
                    towards:[touches.anyObject locationInNode:self]
                ];
            }
            break;
    }
}

- (void) spawnAsteroid
{
    float angle = arc4random_uniform( 360.0 ) * M_PI / 180.0;
    
    CGPoint o = earth.position;
    CGPoint p = CGPointMake( o.x + ASTEROID_SPAWN_DISTANCE, o.y );

    CGFloat xPoint = cosf( angle ) * ( p.x - o.x ) - sinf( angle ) * ( p.y - o.y ) + o.x;
    CGFloat yPoint = sinf( angle ) * ( p.x - o.x ) + cosf( angle ) * ( p.y - o.y ) + o.y;

    CGPoint spawnPoint = CGPointMake( xPoint, yPoint );

    Asteroid *asteroid = [Asteroid new];
    asteroid.position = spawnPoint;

    asteroid.velocity = [VectorUtil normalizeVector:CGVectorMake( o.x - spawnPoint.x, o.y - spawnPoint.y ) toScale:50.];
    
    [self addChild:asteroid];
}

- (void)launchProjectile:(Class)class
    towards:(CGPoint)targetPoint
{
    CGPoint originPoint = self.earthPoint;
    CGVector vector = CGVectorMake( targetPoint.x - originPoint.x, targetPoint.y - originPoint.y);
    
    SKSpriteNode<Projectile> *sprite = [class new];
    
    sprite.position = originPoint;
    [sprite setVector:vector];
    
    [self addChild:sprite];
}


- (void)update:(CFTimeInterval)currentTime
{
    CGPoint earthPosition = earth.position;
    
    calculated = (NSMutableDictionary*)CFBridgingRelease(CFDictionaryCreateMutable(nil, 0, NULL, NULL));
    
    for( SKNode *child in self.children )
    {
        if( child && [child isKindOfClass:Asteroid.class])
        {
            Asteroid *asteroid = (Asteroid *)child;
            CGPoint point1 = asteroid.position;
            CGVector runningVector = CGVectorMake(0.0, 0.0);
            
            for( SKNode *child2 in self.children )
            {
                if( child2 && [child2 isKindOfClass:Asteroid.class])
                {
                    Asteroid *asteroid2 = (Asteroid *)child2;
                    
                    if( asteroid == asteroid2 || (asteroid.physicsBody.categoryBitMask & worldKillerCategory ) != 0 || [calculated[ @(asteroid2.hash).stringValue ] boolValue] == YES )
                    {
                        continue;
                    }
                    
                    CGPoint point2 = asteroid2.position;
                    
                    CGVector vector = [VectorUtil getVectorBetweenPosition:point1 andPosition2:point2 andGravityForce:ASTEROIDAL_GRAVITY_FORCE];
                    runningVector = [VectorUtil addVectors:runningVector and:vector];
                }
            }
            
            runningVector = [VectorUtil addVectors:runningVector and:[VectorUtil getVectorBetweenPosition:point1 andPosition2:earthPosition andGravityForce:PLANETARY_GRAVITY_FORCE]];
        
            asteroid.radialGravity = runningVector;
            
            calculated[ @(asteroid.hash).stringValue ] = @(YES);
        }
    }
    
    Asteroid *newAsteroid = [AsteroidSpawner spawn:currentTime];
    if( newAsteroid )
    {
        [self addChild:newAsteroid];
    }
    
    if( currentTime - lastTime > 1 )
    {
        time++;
        timer.text = [NSString stringWithFormat:@"TIME: %05d",time];
        lastTime = currentTime;
    }
}

- (void) spawnNukeExplostionAt:(CGPoint)point
{
    NukeExplosion *explosion = [NukeExplosion new];
    explosion.position = point;
    [self addChild:explosion];
    
//    [collisionManager spawnAndSetupEmitterAt:point];
}

@end
