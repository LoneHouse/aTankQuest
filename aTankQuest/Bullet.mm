//
//  Bullet.m
//  aTankQuest
//
//  Created by Roman on 04.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Bullet.h"
@implementation Bullet
@synthesize bulletBody;

#define PTM_RATIO 32
#define BULLET_FORCE 190
#define BULLET_RADIUS 0.2

-(id)init{
    if(self==[super init]){
    }
    return self;
}
                          
+(id) node
{
	return [[[self alloc] init] autorelease];
}

-(void)shoot:(CGPoint)source withDirection:(CGPoint)direction inPhysicsWorld:(b2World *)world{
    // Define the tank body.
    b2BodyDef bulletBodyDef;
    bulletBodyDef.userData=self;
    bulletBodyDef.type = b2_dynamicBody;
    bulletBodyDef.position.Set((source.x+4)/PTM_RATIO+BULLET_RADIUS/2, (source.y)/PTM_RATIO+BULLET_RADIUS/2);
    //bulletBodyDef.userData = tankSprite;
    self.bulletBody = world->CreateBody(&bulletBodyDef);
    // Define another box shape for our dynamic body.
    b2CircleShape dynamicBullet;
    dynamicBullet.m_radius=BULLET_RADIUS;
    // Define the dynamic body fixture.
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &dynamicBullet;	
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.3f;
    self.bulletBody->CreateFixture(&fixtureDef);
    b2Vec2 dir;
    dir.Set(direction.x*BULLET_FORCE, direction.y*BULLET_FORCE);
    self.bulletBody->ApplyForce(dir, self.bulletBody->GetPosition());
}

-(void)dealloc{
    [super dealloc];
}
@end
