//
//  VectorUtil.m
//  asteroid-defense
//
//  Created by Bryant Balatbat on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import "VectorUtil.h"

@implementation VectorUtil

+ (CGVector)normalizeVector:(CGVector)vector
    toScale:(CGFloat)scale
{
    CGVector normalizedVector = CGVectorMake(vector.dx, vector.dy);
    float length = [self length:normalizedVector];
    if (length < FLT_EPSILON)
    {
        return vector;
    }
    
    float invLength = scale / length;
    normalizedVector.dx *= invLength;
    normalizedVector.dy *= invLength;
    
    return normalizedVector;
}

+ (CGFloat)length:(CGVector)vector
{
    return sqrtf(vector.dx * vector.dx + vector.dy * vector.dy);
}

+ (CGVector)addVectors:(CGVector)v1 and:(CGVector)v2
{
    return CGVectorMake(v2.dx + v1.dx, v2.dy + v1.dy);
}

+ (CGVector) getVectorBetweenPosition:(CGPoint)p1 andPosition2:(CGPoint)p2 andGravityForce:(float)gravity
{
    CGFloat distance = sqrt( pow( p1.x - p2.x, 2.0) + (pow( p1.y - p2.y, 2.0 )));
    
    CGFloat force = gravity / ( distance * distance);
    CGVector radialGravityForce = CGVectorMake((p2.x - p1.x) * force, (p2.y - p1.y) * force);
    
    return radialGravityForce;
}

+ (CGPoint) rotatePoint:(CGPoint)point aboutPoint:(CGPoint)origin byAngle:(float)angleInRadians
{
    CGFloat xPoint = cosf( angleInRadians ) * ( point.x - origin.x ) - sinf( angleInRadians ) * ( point.y - origin.y ) + origin.x;
    CGFloat yPoint = sinf( angleInRadians ) * ( point.x - origin.x ) + cosf( angleInRadians ) * ( point.y - origin.y ) + origin.y;
    
    return CGPointMake( xPoint, yPoint );
}

@end
