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

@end
