//
//  Tank.m
//  aTankQuest
//
//  Created by Roman on 02.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tank.h"
@implementation Tank
@synthesize direction;
@synthesize tankSprite;
@synthesize tankBody;
@synthesize tankTrunkJoint;
@synthesize wheels,trunk;

#define TANK_MASS 20000
#define WHEELS_COUNT 7
#define PTM_RATIO 32.0
#define FORCE_VALUE 50
#define DEGTORADS(deg) (deg*3.14/180)
#define TRUNC_LEN 2.4


-(void)moveForward{

    for (int i=0; i<[self.wheels count]; i++) {
        b2Body * wheel=(b2Body*)[[self.wheels objectAtIndex:i] pointerValue];
        wheel->SetAngularVelocity(-FORCE_VALUE);
        wheel->SetAngularDamping(FORCE_VALUE/5);
    }
}

-(void)moveBack{
    
    for (int i=0; i<[self.wheels count]; i++) {
        b2Body * wheel=(b2Body*)[[self.wheels objectAtIndex:i] pointerValue];
        wheel->SetAngularVelocity(FORCE_VALUE);
        wheel->SetAngularDamping(FORCE_VALUE/5);
    }
}

-(void)shoot:(b2World *)world{
    
    Bullet *bullet=[Bullet node];
    [self addChild:bullet];

	CGSize tankSize=[self getTankSize];
    b2Vec2 tankCenter=self.tankBody->GetWorldCenter();
    
	//NSLog(@"%f    %f", tankCenter.x, tankCenter.y);
	
    //get current rotate angle
    float angle=self.trunk.truncBody->GetAngle();
    
	//calc point on the circle, that result of trunk rotating
	CGPoint shootPoint=CGPointMake((tankCenter.x+TRUNC_LEN*cos(angle)) * PTM_RATIO, (tankCenter.y+(tankSize.height)+TRUNC_LEN*sin(angle)) * PTM_RATIO);
    //NSLog(@"%f   %f",shootPoint.x,shootPoint.y);
	
    [bullet shoot:shootPoint withDirection:self.direction inPhysicsWorld: world];
    //NSLog(@"fire");
}

-(id)init{
    
    if(self==[super init]){
        self.tankSprite=[CCSprite spriteWithFile:@"Icon.png"];
        self.direction=CGPointMake(1.0, 0.0);
        self.wheels=[[NSMutableArray alloc]init];
		self.trunk=[[[Trunk alloc]init] autorelease];
    }
    return self;
}

-(void)showTankAtPosition:(CGPoint)pos withPhysicsWorld: (b2World*) world connectToGround:(b2Body *)ground{
    self.tankSprite.position=CGPointMake(pos.x, pos.y);
   // [self addChild:self.tankSprite];

    // Define the tank body.
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(pos.x/PTM_RATIO, pos.y/PTM_RATIO);
    
  //  bodyDef.userData = tankSprite;
    self.tankBody = world->CreateBody(&bodyDef);
    [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"shape.plist"];
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:self.tankBody forShapeName:@"Tank"];
    
    //set tank mass
    b2MassData *data=new b2MassData();
    data->mass=TANK_MASS;
    data->I=TANK_MASS*0.6;
    self.tankBody->SetMassData(data);
    
    
    //define the tank's truk
    //[self addChild:self.trunkSprite];
    b2BodyDef trunkDef;
    trunkDef.type=b2_dynamicBody;
    trunkDef.position.Set((pos.x)/PTM_RATIO, (pos.y)/PTM_RATIO);
    //trunkDef.userData = self.trunkSprite;
    self.trunk.truncBody = world->CreateBody(&trunkDef);
    [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"shape.plist"];
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:self.trunk.truncBody forShapeName:@"Trunk"];
    b2RevoluteJointDef revoluteJointDef;
    revoluteJointDef.bodyA=self.tankBody;
    revoluteJointDef.bodyB=self.trunk.truncBody;
    revoluteJointDef.collideConnected=false;
    //define local anchors
    revoluteJointDef.localAnchorA.Set(0,0.6f);
    revoluteJointDef.localAnchorB.Set(-0.3,0.0f);
    //define angle limits
    revoluteJointDef.enableLimit=true;
    self.tankTrunkJoint =(b2RevoluteJoint *)world->CreateJoint(&revoluteJointDef);
    
    
    //create wheels, absorbers and joints
    //tank->prismatic joint->absorber->revolutejoint->wheel
    CGSize tankSize=[self getTankSize];
    float anchor=-2.5;
    
    b2Body *previousAbsorberBody=nil;
    //create wheels
    for(int i=0;i<WHEELS_COUNT;i++){
        //create absorber
        b2BodyDef absorberBodyDef;
        absorberBodyDef.type = b2_dynamicBody;
        absorberBodyDef.position.Set(((pos.x-tankSize.width)+i*20)/PTM_RATIO, (pos.y-40)/PTM_RATIO);
        //bulletBodyDef.userData = tankSprite;
        b2Body *absorberBody = world->CreateBody(&absorberBodyDef);
        // Define another box shape for our dynamic body.
        b2PolygonShape dynamicAbsorber;
        dynamicAbsorber.SetAsBox(0.1, 0.1);
        // Define the dynamic body fixture.
        b2FixtureDef absorberFixture;
        absorberFixture.shape = &dynamicAbsorber;	
        absorberFixture.density = TANK_MASS/3;
        absorberFixture.friction = 0.3f;
        absorberBody->CreateFixture(&absorberFixture);
        
        //create prismatic joint before tank and absorber
        b2PrismaticJointDef tankToAbsorberDef;
        tankToAbsorberDef.Initialize(self.tankBody, absorberBody, absorberBody->GetWorldCenter(), b2Vec2(0,1));

        if(i!=0 && i!=WHEELS_COUNT-1){
            tankToAbsorberDef.localAnchorA.Set(anchor,-1.1f);
            tankToAbsorberDef.lowerTranslation=-0.2;
            tankToAbsorberDef.upperTranslation=0.1f;
        }
        else {
            tankToAbsorberDef.localAnchorA.Set(anchor,-0.7f);
            tankToAbsorberDef.lowerTranslation=0;
            tankToAbsorberDef.upperTranslation=0.1f;
        }
        tankToAbsorberDef.enableLimit=true;
        tankToAbsorberDef.motorSpeed=80.0;
        tankToAbsorberDef.localAnchorB.Set(0,0);
        tankToAbsorberDef.enableMotor=true;
        b2Joint * tankToAbsorberJoint=world->CreateJoint(&tankToAbsorberDef);
        
        if(absorberBody!=nil && previousAbsorberBody!=nil){
            
            b2DistanceJointDef ropeBetweenAbsorbers;
            ropeBetweenAbsorbers.bodyA=previousAbsorberBody;
            ropeBetweenAbsorbers.bodyB=absorberBody;
            ropeBetweenAbsorbers.localAnchorA=b2Vec2(0,0);
            ropeBetweenAbsorbers.localAnchorB=b2Vec2(0,0);
            ropeBetweenAbsorbers.length=0.3f;
            ropeBetweenAbsorbers.frequencyHz=2;
            ropeBetweenAbsorbers.dampingRatio=10;
            b2Joint * ropeJoint=world->CreateJoint(&ropeBetweenAbsorbers);
        }
        
        //make this absorber previous
        previousAbsorberBody=absorberBody;
        
        //create wheels
        b2BodyDef wheelBodyDef;
        wheelBodyDef.type = b2_dynamicBody;
        wheelBodyDef.position.Set(((pos.x-tankSize.width)+i*20)/PTM_RATIO, (pos.y-40)/PTM_RATIO);
        //bulletBodyDef.userData = tankSprite;
        b2Body *wheelBody = world->CreateBody(&wheelBodyDef);
        // Define another box shape for our dynamic body.
        b2CircleShape dynamicWheel;
        if(i!=0 && i!=WHEELS_COUNT-1)
            dynamicWheel.m_radius=0.3f;
        else {
            dynamicWheel.m_radius=0.25f;
        }
        // Define the dynamic body fixture.
        b2FixtureDef fixtureDef;
        fixtureDef.shape = &dynamicWheel;	
        fixtureDef.density = TANK_MASS;
        fixtureDef.friction = 0.3f;
        fixtureDef.restitution=0.5f;
        wheelBody->CreateFixture(&fixtureDef);
        //put wheel body to array
        NSValue * incapsulatedWheel=[NSValue valueWithPointer:wheelBody];
        [self.wheels addObject:incapsulatedWheel];
        
        //create revoluteJoint(between wheel and absorber)
        b2RevoluteJointDef wheelJointDef;
        wheelJointDef.Initialize(absorberBody, wheelBody, wheelBody->GetWorldCenter());
        //define local anchors
        wheelJointDef.localAnchorA.Set(0,0);
        wheelJointDef.localAnchorB.Set(0,0); 
        b2Joint *wheelJoint =(b2RevoluteJoint *)world->CreateJoint(&wheelJointDef);
        anchor+=1.0/WHEELS_COUNT*5.2;
    }
    NSLog(@"Tank shown at (%f ; %f)",pos.x,pos.y);
}

-(CGPoint)getPosition{
    b2Vec2 position=self.tankBody->GetPosition();
    return CGPointMake(position.x, position.y);
}

-(CGSize)getTankSize{
    //get size of trunk
    b2Fixture * fixture= self.tankBody->GetFixtureList();
    b2AABB  b2aabb= fixture->GetAABB();
    b2Vec2 tankSize=b2aabb.GetExtents();
    return CGSizeMake(tankSize.x, tankSize.y);
}


+(id) node
{
	return [[[self alloc] init] autorelease];
}


-(void)rotateTrunk:(float)rotateAngle{
	//get tank rotation
    float tankAngle=self.tankBody->GetAngle();
    
    //rotate trunk
    if(tankAngle/3.14*180>10){
        tankAngle=10*3.14/180;
    }
    if(tankAngle/3.14*180<-10 && rotateAngle/3.14*180>170){
        tankAngle=-10*3.14/180;
    }
    CGSize trunkSize=[self.trunk getTruncSize];
	
    float dy=sin(rotateAngle)*trunkSize.width;
    float dx=sqrt(pow(trunkSize.width,2)+pow(dy, 2));
    
    if(rotateAngle-tankAngle>DEGTORADS(90)){
        dx*=-1;
    }
    self.direction=CGPointMake(dx, dy);
    
    //NSLog(@"%f",dx);
    self.tankTrunkJoint->SetLimits(rotateAngle-tankAngle, rotateAngle-tankAngle+DEGTORADS(1));
}

-(void)dealloc{
    [super dealloc];
    [tankSprite release];
    [wheels release];
	[trunk release];
}

@end
