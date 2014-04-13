//
//  VectorUtil.h
//  asteroid-defense
//
//  Created by Bryant Balatbat on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VectorUtil : NSObject

+ (CGVector)normalizeVector:(CGVector)vector
    toScale:(CGFloat)scale;

+ (CGVector)addVectors:(CGVector)v1 and:(CGVector)v2;

@end
