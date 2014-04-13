//
//  Earth.m
//  asteroid-defense
//
//  Created by Bryant Balatbat on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import "Earth.h"
#import "GameManager.h"

@implementation Earth
{
    BOOL didMoveDuringTouch;
    SKLabelNode *earthLabel;
}

/******************************************************************************/

#pragma mark - Static methods

/******************************************************************************/

+ (SKTexture *)texture
{
    return [self textureWithPercent:1.0];
}

+ (SKTexture *)textureWithPercent:(CGFloat)percent
{
    UIGraphicsBeginImageContext(CGSizeMake(EARTH_RADIUS * 2., EARTH_RADIUS * 2.));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[SKColor
        colorWithRed:percent
        green:percent
        blue:percent
        alpha:1.f
    ] setFill];
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
        [self prepareLabels];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches
    withEvent:(UIEvent *)event
{
    didMoveDuringTouch = NO;
}

- (void)touchesMoved:(NSSet *)touches
    withEvent:(UIEvent *)event
{
    didMoveDuringTouch = YES;
}
- (void)touchesEnded:(NSSet *)touches
    withEvent:(UIEvent *)event
{
    if (didMoveDuringTouch)
    {
        [self
            handleTouchesEnded:touches
        ];
        didMoveDuringTouch = NO;
    }
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

- (void)prepareLabels
{
    earthLabel = [self
        labelForString:@"EARTH"
        andPosition:CGPointMake(0, -5)
        withFontSize:12
    ];
    
    [self addChild: earthLabel];
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
    label.fontColor = SKColor.blackColor;
    label.position = position;
    return label;
}

/******************************************************************************/

#pragma mark - Launcher state methods

/******************************************************************************/

- (void)handleTouchesEnded:(NSSet *)touches
{
    [self.delegate
        earth:self
        didRequestToFireProjectileWithTouches:touches
    ];
}

/******************************************************************************/

#pragma mark - Health related methods

/******************************************************************************/


- (void)updateHealth
{
    CGFloat percent = MAX(0.0, (GameManager.sharedManager.earthHealth / BASE_EARTH_HEALTH));
    [self setTexture:[Earth textureWithPercent:percent]];
    [earthLabel setFontColor:[UIColor
        colorWithRed:(1.f - percent)
        green:(1.f - percent)
        blue:(1.f - percent)
        alpha:1.f]
    ];
}
@end
