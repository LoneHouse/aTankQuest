//
//  Trunk.m
//  aTankQuest
//
//  Created by Roman Sidorakin on 14.05.12.
//  Copyright (c) 2012 Rus Wizards. All rights reserved.
//

#import "Trunk.h"

@implementation Trunk
@synthesize truncBody,trunkSprite;

-(CGSize) getTruncSize{
    //get size of trunk
    b2Fixture * fixture= self.truncBody->GetFixtureList();
    b2AABB  b2aabb= fixture->GetAABB();
    b2Vec2 trunkSize=b2aabb.GetExtents();
    return CGSizeMake(trunkSize.x, trunkSize.y);
}

-(void)dealloc{
	[super	dealloc];
	[trunkSprite release];
}
@end
