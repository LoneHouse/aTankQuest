//
//  MyCamera.m
//  aTankQuest
//
//  Created by Roman on 27.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyCamera.h"
#import "CCScheduler.h"

#define DEGTORADS(deg) (deg*3.14/180)
#define ROTATION_COEF 70

@interface MyCamera()
-(void) setUpVector;
-(void) setupCameraLimits;
-(void) setUpTrunkLimits;
-(void) correctCamera;
-(void) steppedRotate:(NSNumber*)rotateAng;
@end

@implementation MyCamera
@synthesize prevRotateAngle;
@synthesize rotateAngle;
@synthesize cameraLayer;

static BOOL largerAngle=NO;
static float x,y;
static float rotationDx, rotationDy;

-(id)initWithLayer:(CCLayer*) layer{
    if(self==[super init]){
        self.cameraLayer=layer;
    }
    return self;
}

-(void)rotateToAngle:(float)rotateAng{
    #define num 10
	if ((rotateAng<DEGTORADS(90) && self.prevRotateAngle>=DEGTORADS(90)) && largerAngle) {
		self.prevRotateAngle=DEGTORADS(179.9);
		self.rotateAngle=DEGTORADS(180);
	}
	else{
		
		self.rotateAngle=rotateAng;
		float step=(self.rotateAngle-self.prevRotateAngle)/num;
		//NSLog(@"%f  %f  %f",step,self.rotateAngle, self.prevRotateAngle);
		for(int i=0;i<num;i++){
			[self performSelector:@selector(steppedRotate:) withObject:[NSNumber numberWithFloat:self.prevRotateAngle+step]];
		}
		self.prevRotateAngle=self.rotateAngle;
	}
}

-(void)steppedRotate:(NSNumber*)rotateAng{
    self.rotateAngle=[rotateAng floatValue];
    [self setUpTrunkLimits];
    [self setupCameraLimits];
    [self setUpVector];
    [self correctCamera];
}

//move camera while rotating(tank also at left)
-(void) correctCamera{
    if(self.rotateAngle<DEGTORADS(90)){
        float centerX,centerY,centerZ;
        [self.cameraLayer.camera centerX:&centerX centerY:&centerY centerZ:&centerZ];
        rotationDx=self.rotateAngle*ROTATION_COEF; 
        rotationDy=(self.rotateAngle)*ROTATION_COEF/3;
    }
    
    if(self.rotateAngle<=DEGTORADS(0)){
        rotationDx=0;
        rotationDy=0;
    }
    
    if(self.rotateAngle>DEGTORADS(90) && self.rotateAngle<DEGTORADS(180)){
        float centerX,centerY,centerZ;
        [self.cameraLayer.camera centerX:&centerX centerY:&centerY centerZ:&centerZ];
        rotationDx=(DEGTORADS(180)-self.rotateAngle)*ROTATION_COEF; 
        rotationDy=self.rotateAngle*ROTATION_COEF/2.5;
    }
}

-(void)setUpTrunkLimits{
    // limits for trunk
    if(largerAngle==NO && self.rotateAngle>DEGTORADS(120)){
        largerAngle=YES;
    }
    
    if(largerAngle==YES && self.rotateAngle<DEGTORADS(120)){
        largerAngle=NO;
    }
    
    if((largerAngle==NO && self.prevRotateAngle>DEGTORADS(120) && self.rotateAngle>=DEGTORADS(179)) || 
       (largerAngle==NO && self.prevRotateAngle>DEGTORADS(120) && self.rotateAngle<=DEGTORADS(0)) )
    {
        self.rotateAngle=DEGTORADS(179);
    }
}

-(void)setUpVector{
    //calculate up-vector for camera
    x=-sin(self.rotateAngle);
    y=sqrt(1-pow(x, 2));
    
    //for rotating after 90 degres
    if(self.rotateAngle>DEGTORADS(90)){
        y*=-1;
    }
    //set up-vector for camera
    [self.cameraLayer.camera setUpX:x upY:y upZ:0];
}

//limits for camera rotating
-(void) setupCameraLimits{
    if(self.rotateAngle<0){
        self.rotateAngle=0;
    }
    if(self.rotateAngle>=DEGTORADS(180)){
        self.rotateAngle=DEGTORADS(180);
    }
}

-(void)setupCamera:(CGPoint)viewPoint{
    [self.cameraLayer.camera setCenterX:viewPoint.x+rotationDx centerY:viewPoint.y+rotationDy  centerZ:0];
    [self.cameraLayer.camera setEyeX:viewPoint.x+rotationDx eyeY:viewPoint.y+rotationDy  eyeZ:[CCCamera getZEye]];
}

-(void)dealloc{
    [super dealloc];
    [cameraLayer release];
}
@end
