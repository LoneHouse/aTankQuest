//
//  HelloWorldLayer.h
//  aTankQuest
//
//  Created by Roman on 02.04.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "Tank.h"
#import "MyCamera.h"
#import "GameMenuViewController.h"
#import "MyContactListener.h"

@interface GameLayer : CCLayer
{
	b2World* world;
	GLESDebugDraw *m_debugDraw;
}

@property (retain, nonatomic) Tank* tank;
@property(nonatomic ) b2Body* groundBody;
@property(nonatomic,retain) MyCamera* myCamera;
@property(nonatomic) MyContactListener * myContactListener;
// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
@end
