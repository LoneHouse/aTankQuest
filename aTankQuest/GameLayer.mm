//
//  HelloWorldLayer.mm
//  aTankQuest
//
//  Created by Roman on 02.04.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "GameLayer.h"
#import "Tank.h"
#import "GB2ShapeCache.h"


//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32.0
#define DEGTORADS(deg) (deg*3.14/180)

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
    kTagTankObject=4,
};


@interface GameLayer()
-(void) rotateCamera;
@end

static float rotateAngle;

@implementation GameLayer
@synthesize tank;
@synthesize groundBody;
@synthesize myCamera;
@synthesize myContactListener;

static GameMenuViewController * menu;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	// add layer as a child to scene
	[scene addChild: layer];

	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
		
		// Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, -10.0f);
		
		// Do we want to let bodies sleep?
		// This will speed up the physics simulation
		bool doSleep = true;
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2World(gravity, doSleep);
		
		world->SetContinuousPhysics(true);
		
		// Debug Draw functions
		m_debugDraw = new GLESDebugDraw( PTM_RATIO );
		world->SetDebugDraw(m_debugDraw);
		
		uint32 flags = 0;
		flags += b2DebugDraw::e_shapeBit;
		flags += b2DebugDraw::e_jointBit;
//		flags += b2DebugDraw::e_aabbBit;
//		flags += b2DebugDraw::e_pairBit;
		flags += b2DebugDraw::e_centerOfMassBit;
		m_debugDraw->SetFlags(flags);		
		
        // Define the ground body.
		b2BodyDef groundBodyDef;
		groundBodyDef.position.Set(0, 0); // bottom-left corner
		groundBodyDef.type=b2_staticBody;
		// Call the body factory which allocates memory for the ground body
		// from a pool and creates the ground box shape (also from a pool).
		// The body is also added to the world.
		self.groundBody = world->CreateBody(&groundBodyDef);
        
		//create camera
        self.myCamera=[[MyCamera alloc]initWithLayer:self];
        
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"shape.plist"];
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:self.groundBody forShapeName:@"World"];
        
        self.tank=[Tank node];
        [self addChild:self.tank z:0 tag:kTagTankObject];
        
        CGPoint p=CGPointMake(-2500, 250);
        [self.tank showTankAtPosition: p withPhysicsWorld:world connectToGround:self.groundBody];
        
        //setContactListener
        self.myContactListener=new MyContactListener();
        //myContactListener->world=world;
        world->SetContactListener((b2ContactListener*)myContactListener);
        
        //create and show menu

        if(!menu){
            menu=[[GameMenuViewController alloc]initWithNibName:@"GameMenuViewController" bundle:[NSBundle mainBundle]];
            [[[CCDirector sharedDirector]openGLView]addSubview:menu.view];
        }
        
        [self schedule: @selector(tick:)];
        [self schedule: @selector(rotateCamera)];
	}
	return self;
}

-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

}


-(void) tick: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
    
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);

	//remove deleted objects
	std::vector<b2Body *>toDestroy; 
	std::vector<MyContact>::iterator pos;
//	for(pos = self.myContactListener->_contacts.begin(); pos != self.myContactListener->_contacts.end(); ++pos) {
//		MyContact contact = *pos;
//	
//		b2Body *bodyA = contact.fixtureA->GetBody();
//		b2Body *bodyB = contact.fixtureB->GetBody();
//		
//		if ([((id)bodyA->GetUserData()) isKindOfClass:[Bullet class]]) {
//			//self.myContactListener->_contacts.erase(pos);
//			bodyA->SetActive(false);
//			bodyA->SetTransform(b2Vec2(-10000,0), 0);
//			//world->DestroyBody(bodyA);
//			NSLog(@"The bullet colision");
//		}
//		else if ([((id)bodyB->GetUserData()) isKindOfClass:[Bullet class]]) {
//			//self.myContactListener->_contacts.erase(pos);
//			bodyB->SetActive(false);
//			bodyB->SetTransform(b2Vec2(-10000,0), 0);
//			//world->DestroyBody(bodyB);
//			NSLog(@"The bullet colision");
//			
//			
//		}
		
	//}
	
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}
    
    
    CGPoint tankPoint=[self.tank getPosition]; 
    CGSize tankSize=[self.tank getTankSize]; 
    //set anchor
    self.anchorPoint=CGPointMake((tankPoint.x/PTM_RATIO + tankSize.width/1.2f*PTM_RATIO)/PTM_RATIO, (tankPoint.y/PTM_RATIO+tankSize.height*PTM_RATIO)/PTM_RATIO);
    //set camera viewPoint
    CGPoint viewPoint=CGPointMake((tankPoint.x-tankSize.width/3.2f*PTM_RATIO)*PTM_RATIO,(tankPoint.y-tankSize.height/3.2f*PTM_RATIO)*PTM_RATIO);
    [self.myCamera setupCamera:viewPoint];
    //rotate trunk
    [self.tank rotateTrunk:self.myCamera.rotateAngle];
}

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchPoint= [self convertTouchToNodeSpace:touch];
    //get winsize coordinates
    CGSize winSize=[[CCDirector sharedDirector] winSize];
    //translate coordinates to rotated coordinates
    float xRot,yRot,widthRot,heightRot;
    xRot=touchPoint.x*sin(self.myCamera.rotateAngle+DEGTORADS(90))+touchPoint.y*cos(self.myCamera.rotateAngle+DEGTORADS(90));
    yRot=touchPoint.y*cos(self.myCamera.rotateAngle+DEGTORADS(90))-touchPoint.x*sin(self.myCamera.rotateAngle+DEGTORADS(90));
    
    //translate width and size to rotated coords
    widthRot=winSize.width*sin(self.myCamera.rotateAngle+DEGTORADS(90))+winSize.height*cos(self.myCamera.rotateAngle+DEGTORADS(90));
    heightRot=winSize.height*cos(self.myCamera.rotateAngle+DEGTORADS(90))-winSize.width*sin(self.myCamera.rotateAngle+DEGTORADS(90));
    
    //get tank position
    CGPoint tankPos=[self.tank getPosition];
    tankPos=CGPointMake(tankPos.x*PTM_RATIO, tankPos.y*PTM_RATIO);
    
    //NSLog(@"%f   %f",touchPoint.x,tankPos.x);
    if(touchPoint.x>20 && touchPoint.x<180 &&
       touchPoint.y>45 && touchPoint.y<155){
        [self.tank shoot:world];
    }
    else{
        if(xRot>=widthRot/2)
            [self.tank schedule:@selector(moveForward)];
        else {
            [self.tank schedule:@selector(moveBack)];
        }
    }
    return YES;
}
                                               
-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    [self.tank unscheduleAllSelectors];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
	}
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;

	#define kFilterFactor 0.4f
    //#define kFilterFactor 1.0f	// don't use filter. the code is here just as an example
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
    //calculate rotation angle
    rotateAngle=atan2(accelY, -accelX);
    
    prevX=accelX;
    prevY=accelY;
}

-(void)rotateCamera{
    //rotate camera to rotate angle;
    [self.myCamera rotateToAngle:rotateAngle];

}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    [tank release];
    [myCamera release];
	// in case you have something to dealloc, do it in this method
	delete world;
	world = NULL;
	delete m_debugDraw;
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
