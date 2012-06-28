//
//  Trunk.h
//  aTankQuest
//
//  Created by Roman Sidorakin on 14.05.12.
//  Copyright (c) 2012 Rus Wizards. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "Box2D.h"

@interface Trunk : CCLayer
@property(nonatomic,retain) CCSprite* trunkSprite;
@property(nonatomic) b2Body* truncBody;

-(CGSize) getTruncSize;
@end
