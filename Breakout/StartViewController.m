//
//  StartViewController.m
//  Breakout
//
//  Created by Robert Figueras on 5/25/14.
//  Copyright (c) 2014 PHMobileMakers. All rights reserved.
//

#import "StartViewController.h"
#import "ViewController.h"
#import "BallView.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>


@interface StartViewController () <UICollisionBehaviorDelegate>
@property (strong, nonatomic) IBOutlet UIButton *onePlayerStartButton;
@property (strong, nonatomic) IBOutlet UIButton *twoPlayerStartButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLable;
@property (strong, nonatomic) IBOutlet BallView *ballViewTitle;
@property UIDynamicAnimator *dynamicAnimator;
@property UIPushBehavior *pushBehavior;
@property UICollisionBehavior *collisionBehavior;
@property UIDynamicItemBehavior *ballDynamicBehavior;
@property UIDynamicItemBehavior *titleDynamicBehavior;
@property (strong, nonatomic) AVAudioPlayer* avPlayer;

@end

@implementation StartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];

    self.dynamicAnimator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];

    self.pushBehavior = [[UIPushBehavior alloc]initWithItems:@[self.ballViewTitle] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.pushDirection = CGVectorMake(0.5,0.5);
    self.pushBehavior.active = YES;
    self.pushBehavior.magnitude = 0.8;
    [self.dynamicAnimator addBehavior:self.pushBehavior];

    self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.titleLable, self.ballViewTitle]];
    self.collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
    self.collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    self.collisionBehavior.collisionDelegate = self;
    [self.dynamicAnimator addBehavior:self.collisionBehavior];

    self.ballDynamicBehavior = [[UIDynamicItemBehavior alloc]initWithItems:@[self.ballViewTitle]];
    self.ballDynamicBehavior.allowsRotation = NO;
    self.ballDynamicBehavior.friction = 0.0;
    self.ballDynamicBehavior.elasticity = 1.0;
    self.ballDynamicBehavior.resistance = 0.0;
    [self.dynamicAnimator addBehavior:self.ballDynamicBehavior];

    self.titleDynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.titleLable]];
    self.titleDynamicBehavior.allowsRotation = NO;
    self.titleDynamicBehavior.density = 1000000;
    [self.dynamicAnimator addBehavior:self.titleDynamicBehavior];

    [self setRoundedView:self.ballViewTitle toDiameter:25.0];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    NSURL* musicFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Spy Trance" ofType:@"m4a"]];
    self.avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile error:nil];
    [self.avPlayer prepareToPlay];
    self.avPlayer.volume = 0.7;
    self.avPlayer.numberOfLoops = -1;
    [self.avPlayer play];
}

-(void)setRoundedView:(UIView *)roundedView toDiameter:(float)newSize;
{
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.avPlayer stop];
    if ([segue.identifier isEqualToString:@"twoPlayerModeSegue"]) {
        ViewController *nextVC = segue.destinationViewController;
        nextVC.isTwoPlayerMode = YES;
    }
}

-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p
{
    self.titleLable.alpha = 1.0;

    if (self.titleLable.backgroundColor == [UIColor yellowColor]) {
        [UIView animateWithDuration:2.0 animations:^{
            self.titleLable.backgroundColor = [UIColor orangeColor];
            self.titleLable.alpha = 0.0;
        }];
        self.ballViewTitle.backgroundColor = [UIColor redColor];
    }
    else if (self.titleLable.backgroundColor == [UIColor orangeColor]) {
        [UIView animateWithDuration:2.0 animations:^{
            self.titleLable.backgroundColor = [UIColor redColor];
            self.titleLable.alpha = 0.0;
        }];
        self.ballViewTitle.backgroundColor = [UIColor whiteColor];
    }
    else if (self.titleLable.backgroundColor == [UIColor redColor]) {
        [UIView animateWithDuration:2.0 animations:^{
            self.titleLable.backgroundColor = [UIColor whiteColor];
            self.titleLable.alpha = 0.0;
        }];
        self.ballViewTitle.backgroundColor = [UIColor yellowColor];
    }
    else{
        [UIView animateWithDuration:2.0 animations:^{
            self.titleLable.backgroundColor = [UIColor yellowColor];
            self.titleLable.alpha = 0.0;
        }];
        self.ballViewTitle.backgroundColor = [UIColor orangeColor];
    }
}

@end
