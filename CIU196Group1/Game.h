//
//  Game.h
//  CIU196Group1
//
//  Created by saqirltu on 04/12/13.
//  Copyright (c) 2013 Eric Zhang, Robert Sebescen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionController.h"

#import "Player.h"

@interface Game : NSObject

+(Game*) sharedGame;
-(BOOL)saveChanges;
- (void)reset;

@property (nonatomic, strong) Player *myself;
@property NSInteger sessionID;
@property (nonatomic, strong) NSMutableArray *heroes;
@property NSInteger host;   //index of the host in heroes array
@property BOOL waiting;     //true if the host is waiting in new players page
@property SessionController* sessionController;


//-(void)updateStatus: (NSMutableArray *)heroes;

- (NSUInteger)count;
- (void)addHero:(Player *)ahero;
- (Player* )heroAtIndex:(NSUInteger)index;

@end