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
#import "Miner.h"
#import "Earth.h"
#import "VectorUtil.h"

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
    
    NSSet *nodes;
    ProjectileType projectileType;
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

-(id)initWithSize:(CGSize)size
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
        
        lastLaunch = 0;
        
    }
    return self;
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
    
    [NSNotificationCenter.defaultCenter
        addObserver:self
        selector:@selector(onAcquiredReadyNuke)
        name:kDidAcquireReadyNuke
        object:GameManager.sharedManager
    ];
}

- (void)onAcquiredReadyNuke
{
    [self updateNukesReady];
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
    
    NSMutableDictionary *calculated = [NSMutableDictionary new];
    
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
                    
                    if( asteroid == asteroid2 || asteroid.hidden == YES || asteroid2.hidden == YES || [calculated[ asteroid2 ] boolValue] == YES )
                    {
                        continue;
                    }
                    
                    CGPoint point2 = asteroid2.position;
                    
                    CGVector vector = [self getVectorBetweenPosition:point1 andPosition2:point2 andGravityForce:ASTEROIDAL_GRAVITY_FORCE];
                    runningVector = [VectorUtil addVectors:runningVector and:vector];
                }
            }
            
            runningVector = [VectorUtil addVectors:runningVector and:[self getVectorBetweenPosition:point1 andPosition2:earthPosition andGravityForce:PLANETARY_GRAVITY_FORCE]];
        
            asteroid.radialGravity = runningVector;
            
            calculated[ asteroid ] = @(YES);
        }
    }
    
    if( currentTime - lastLaunch > LAUNCH_INTERVAL )
    {
        [self spawnAsteroid];
        lastLaunch = currentTime;
    }
}

- (CGVector) getVectorBetweenPosition:(CGPoint)p1 andPosition2:(CGPoint)p2 andGravityForce:(float)gravity
{
    CGFloat distance = sqrt( pow( p1.x - p2.x, 2.0) + (pow( p1.y - p2.y, 2.0 )));
    
    CGFloat force = gravity / ( distance * distance);
    CGVector radialGravityForce = CGVectorMake((p2.x - p1.x) * force, (p2.y - p1.y) * force);
    
    return radialGravityForce;
}

@end
