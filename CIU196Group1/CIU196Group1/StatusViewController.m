//
//  StatusViewController.m
//  CIU196Group1
//
//  Created by saqirltu on 08/12/13.
//  Copyright (c) 2013 Eric Zhang, Robert Sebescen. All rights reserved.
//

#import "StatusViewController.h"
#import "Game.h"

@interface StatusViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *player1;
@property (strong, nonatomic) IBOutlet UIImageView *player2;
@property (strong, nonatomic) IBOutlet UIImageView *player3;
@property (strong, nonatomic) IBOutlet UIImageView *player4;
@property (strong, nonatomic) IBOutlet UIImageView *player5;
@property (strong, nonatomic) IBOutlet UIImageView *player6;
@property (strong, nonatomic) IBOutlet UIImageView *player7;
@property (strong, nonatomic) IBOutlet UIImageView *player8;
@property (strong, nonatomic) IBOutlet UIImageView *player9;
@property (strong, nonatomic) IBOutlet UIImageView *player10;
@property (strong, nonatomic) IBOutlet UIImageView *player11;
@property (strong, nonatomic) IBOutlet UIImageView *player12;
@property (strong, nonatomic) IBOutlet UIImageView *player13;

@end

@implementation StatusViewController

@synthesize player1, player2, player3, player4, player5, player6, player7, player8, player9, player10, player11, player12, player13;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



NSMutableArray *players;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    players = [NSMutableArray arrayWithObjects: player1, player2, player3, player4, player5, player6, player7, player8, player9, player10, player11, player12, player12, player13,nil];
    
    
    
    for (int i=0; i < [[Game sharedGame]count]; i++) {
        [(UIImageView*)[players objectAtIndex:i] setImage:[[[Game sharedGame] heroAtIndex:i] image]];
    }
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    NSLog(@"did receive memory warning");
}

@end