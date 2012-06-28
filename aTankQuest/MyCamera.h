//
//  MyCamera.h
//  aTankQuest
//
//  Created by Roman on 27.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCCamera.h"
#import "CCLayer.h"

@interface MyCamera : CCLayer

@property(nonatomic,readwrite) float rotateAngle;
@property(nonatomic,readwrite) float prevRotateAngle;
@property(nonatomic,retain) CCLayer* cameraLayer;
-(void) rotateToAngle:(float)angle;
-(id)initWithLayer:(CCLayer*) layer;

-(void) setupCamera:(CGPoint)vievPoint;
@end

