//
//  Tank.h
//  aTankQuest
//
//  Created by Roman on 02.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "Box2D.h"
#import "Bullet.h"
#import "GLES-Render.h"
#import "GB2ShapeCache.h"
#import "Trunk.h"

@interface Tank : CCLayer

@property(nonatomic) CGPoint direction;
@property(nonatomic, retain) CCSprite* tankSprite;
@property(nonatomic) b2Body* tankBody;
@property(nonatomic,retain) Trunk* trunk;


@property(nonatomic) b2RevoluteJoint* tankTrunkJoint;
@property(nonatomic,retain) NSMutableArray *wheels;

-(void) moveForward;
-(void) moveBack;
-(void) shoot:(b2World *) world;
-(CGPoint) getPosition;
+(id) node;
-(void) showTankAtPosition: (CGPoint) postition withPhysicsWorld: (b2World*) world connectToGround: (b2Body*) ground;
-(CGSize) getTankSize;
-(void)rotateTrunk:(float)rotateAngle;
@end
