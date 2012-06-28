//
//  GB2ShapeCache.h
//  rusUFO
//
//  Created by Eugene Syrtcov on 1/18/12.
//  Copyright (c) 2012 com.ruswizards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Box2D.h>

/**
 * Shape cache 
 * This class holds the shapes and makes them accessible 
 * The format can be used on any MacOS/iOS system
 */
@interface GB2ShapeCache : NSObject 
{
    NSMutableDictionary *shapeObjects_;
    float ptmRatio_;
}

+ (GB2ShapeCache *)sharedShapeCache;

/**
 * Adds shapes to the shape cache
 * @param plist name of the plist file to load
 */
-(void) addShapesWithFile:(NSString*)plist;

/**
 * Adds fixture data to a body
 * @param body body to add the fixture to
 * @param shape name of the shape
 */
-(void) addFixturesToBody:(b2Body*)body forShapeName:(NSString*)shape;

/**
 * Returns the anchor point of the given sprite
 * @param shape name of the shape to get the anchorpoint for
 * @return anchorpoint
 */
-(CGPoint) anchorPointForShape:(NSString*)shape;

/**
 * Returns the ptm ratio
 */
-(float) ptmRatio;

@end
