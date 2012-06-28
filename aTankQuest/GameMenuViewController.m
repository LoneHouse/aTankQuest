//
//  GameMenuViewController.m
//  aTankQuest
//
//  Created by Roman on 27.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameMenuViewController.h"
#import "cocos2d.h"

@interface GameMenuViewController ()

@end

@implementation GameMenuViewController
@synthesize game;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)rotateViewToAngle:(float)angle{
    self.view.layer.transform=CATransform3DMakeRotation(angle, 0, 0, 1);
}

-(void)btnClick:(id)sender{
    [[CCDirector sharedDirector]resume];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFlipAngular transitionWithDuration:2 scene:[GameLayer scene]]];
    
}

@end
