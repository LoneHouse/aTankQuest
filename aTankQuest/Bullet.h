//
//  Bullet.h
//  aTankQuest
//
//  Created by Roman on 04.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "MyContactListener.h"
#import <vector>
#import <algorithm>
#import <set>

@interface Bullet : CCLayer

@property (nonatomic) b2Body *bulletBody;

+(id) node;
-(void) shoot:(CGPoint) source withDirection:(CGPoint) direction inPhysicsWorld:(b2World *) world;
@end