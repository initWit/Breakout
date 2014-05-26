//
//  StartViewController.m
//  Breakout
//
//  Created by Robert Figueras on 5/25/14.
//  Copyright (c) 2014 PHMobileMakers. All rights reserved.
//

#import "StartViewController.h"
#import "ViewController.h"

@interface StartViewController ()
@property (strong, nonatomic) IBOutlet UIButton *onePlayerStartButton;

@property (strong, nonatomic) IBOutlet UIButton *twoPlayerStartButton;

@end

@implementation StartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"twoPlayerModeSegue"]) {
        ViewController *nextVC = segue.destinationViewController;
        nextVC.isTwoPlayerMode = YES;
    }
}

@end
