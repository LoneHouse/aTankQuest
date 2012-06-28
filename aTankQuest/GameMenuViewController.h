//
//  GameMenuViewController.h
//  aTankQuest
//
//  Created by Roman on 27.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GameLayer;

@interface GameMenuViewController : UIViewController

@property(nonatomic,retain) GameLayer *game;
-(IBAction)btnClick:(id)sender;
-(void) rotateViewToAngle:(float) angle;
@end
