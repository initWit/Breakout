//
//  ViewController.m
//  Breakout
//
//  Created by Timothy P. Hennig on 5/22/14.
//  Copyright (c) 2014 PHMobileMakers. All rights reserved.
//

#import "ViewController.h"
#import "PaddleView.h"
#import "BallView.h"
#import "BlockView.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <UICollisionBehaviorDelegate, BallViewDelegate>
@property (weak, nonatomic) IBOutlet PaddleView *paddleView;
@property (weak, nonatomic) IBOutlet BallView *ballView;
@property (strong, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) NSNumber *score;
@property (strong, nonatomic) IBOutlet UILabel *playerOneScoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *playerTwoScoreLabel;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property UIDynamicAnimator *dynamicAnimator;
@property UIPushBehavior *pushBehavior;
@property UICollisionBehavior *collisionBehavior;
@property UIDynamicItemBehavior *paddleDynamicBehavior;
@property UIDynamicItemBehavior *ballDynamicBehavior;
@property UISnapBehavior *snapBehavior;
@property NSMutableArray *arrayOfBlocks;
@property CAEmitterLayer *myEmitter;
@property NSNumber *playerOneScore;
@property NSNumber *playerTwoScore;
@property BOOL isPlayerOnePlaying;
@property BOOL isGameOver;
@property (strong, nonatomic) AVAudioPlayer* avPlayer;
@property (strong, nonatomic) NSURL* beepSoundURL;
@property (strong, nonatomic) AVAudioPlayer* avPlayerBg;
@property (strong, nonatomic) NSURL* backgroundMusicURL;

@end

@implementation ViewController

SystemSoundID beepCoinSound;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.ballView.delegate = self;
    self.arrayOfBlocks = [[NSMutableArray alloc]init];
    for (id eachUIelement in self.view.subviews) {
        if ([eachUIelement isKindOfClass:[BlockView class]]) {
            [self.arrayOfBlocks addObject:eachUIelement];
        }
    }
    for (BlockView* eachBlockView in self.arrayOfBlocks) {
        eachBlockView.hitLevel = [NSNumber numberWithInt:eachBlockView.tag];
        if (eachBlockView.tag == 2) {
            eachBlockView.backgroundColor = [UIColor orangeColor];
        }
        if (eachBlockView.tag == 3) {
            eachBlockView.backgroundColor = [UIColor redColor];
        }
    }
    self.dynamicAnimator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    self.pushBehavior = [[UIPushBehavior alloc]initWithItems:@[self.ballView] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.pushDirection = CGVectorMake(0.5,0.5);
    self.pushBehavior.active = YES;
    self.pushBehavior.magnitude = 0.75;

    self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:self.arrayOfBlocks];
    [self.collisionBehavior addItem:self.paddleView];
    [self.collisionBehavior addItem:self.ballView];
    self.collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
    self.collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    self.collisionBehavior.collisionDelegate = self;
    [self.dynamicAnimator addBehavior:self.collisionBehavior];

    self.paddleDynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:self.arrayOfBlocks];
    [self.paddleDynamicBehavior addItem:self.paddleView];
    self.paddleDynamicBehavior.allowsRotation = NO;
    self.paddleDynamicBehavior.density = 100000;
    [self.dynamicAnimator addBehavior:self.paddleDynamicBehavior];

    self.ballDynamicBehavior = [[UIDynamicItemBehavior alloc]initWithItems:@[self.ballView]];
    self.ballDynamicBehavior.allowsRotation = NO;
    self.ballDynamicBehavior.friction = 0.0;
    self.ballDynamicBehavior.elasticity = 1.0;
    self.ballDynamicBehavior.resistance = 0.0;
    [self.dynamicAnimator addBehavior:self.ballDynamicBehavior];

    self.snapBehavior = [[UISnapBehavior alloc] initWithItem:self.ballView snapToPoint:self.view.center];

    self.paddleView.layer.cornerRadius = 10.0;
    [self setRoundedView:self.ballView toDiameter:40.0];

    self.scoreLabel.text = @"0";
    [self.backButton setHidden:YES];

    if (self.isTwoPlayerMode) {
        self.playerOneScore = [NSNumber numberWithInt:0];
        self.playerTwoScore = [NSNumber numberWithInt:0];
        self.instructionsLabel.text = @"Player One - Tap Ball to Start";
        self.scoreLabel.text = @"";
        self.isPlayerOnePlaying = YES;
    }
    else
    {
        [self.playerOneScoreLabel setHidden:YES];
        [self.playerTwoScoreLabel setHidden:YES];
    }
    NSString *beepCoinPath = [[NSBundle mainBundle] pathForResource:@"beepCoin" ofType:@"caf"];
    NSURL *beepCoinURL = [NSURL fileURLWithPath:beepCoinPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)beepCoinURL, &beepCoinSound);
    self.isGameOver = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    self.backgroundMusicURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Spy Trance" ofType:@"m4a"]];
    self.avPlayerBg = [[AVAudioPlayer alloc] initWithContentsOfURL:self.backgroundMusicURL error:nil];
    [self.avPlayerBg prepareToPlay];
    self.avPlayerBg.volume = 0.4;
    self.avPlayerBg.numberOfLoops = -1;
    [self.avPlayerBg play];
}


- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p
{
    if ([item1 isKindOfClass:[BlockView class]] || [item2 isKindOfClass:[BlockView class]])
    {
        BlockView *collidedBlock = (BlockView *)item1;
        if ([item2 isKindOfClass:[BlockView class]]) {
            collidedBlock = (BlockView *)item2;
        }
        if (!self.isTwoPlayerMode) {
            int currentScore = self.score.intValue;
            currentScore += collidedBlock.tag;
            self.score = [NSNumber numberWithInt:currentScore];
            self.scoreLabel.text = [NSString stringWithFormat:@"%i", currentScore];
        }
        else
        {
            if (self.isPlayerOnePlaying) {
                int currentScore = self.playerOneScore.intValue;
                currentScore += collidedBlock.tag;
                self.playerOneScore = [NSNumber numberWithInt:currentScore];
                self.playerOneScoreLabel.text = [NSString stringWithFormat:@"Player One: %i", currentScore];
            }
            else
            {
                int currentScore = self.playerTwoScore.intValue;
                currentScore += collidedBlock.tag;
                self.playerTwoScore = [NSNumber numberWithInt:currentScore];
                self.playerTwoScoreLabel.text = [NSString stringWithFormat:@"Player Two: %i", currentScore];
            }
        }


        collidedBlock.hitLevel = [NSNumber numberWithInt:[collidedBlock.hitLevel intValue]-1];

        if (collidedBlock.hitLevel.intValue == 2)
        {
            [UIView animateWithDuration:0.6 animations:^{
                collidedBlock.backgroundColor = [UIColor orangeColor];
            }];
        }
        else if (collidedBlock.hitLevel.intValue == 1)
        {
            [UIView animateWithDuration:0.6 animations:^{
                collidedBlock.backgroundColor = [UIColor yellowColor];
            }];
        }
        else
        {
            [UIView animateWithDuration:0.6 animations:^{
                collidedBlock.backgroundColor = [UIColor whiteColor];
                collidedBlock.alpha = 0.0;
            }];
            [self performSelector:@selector(removeBlockFromSuperView:) withObject:collidedBlock afterDelay:0.6];
        }
    }
    AudioServicesPlaySystemSound(beepCoinSound);
}


-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    if (p.y >= 565.0)
    {
        if (!self.isTwoPlayerMode) {
            self.scoreLabel.text = [NSString stringWithFormat:@"Your Score: %i", self.score.intValue];
            [self.collisionBehavior removeItem:self.paddleView];
            self.snapBehavior.damping = 0.6;
            [self.dynamicAnimator addBehavior:self.snapBehavior];
            [UIView animateWithDuration:0.2 animations:^{
                self.instructionsLabel.alpha = 1;
            }];
            [self setRoundedView:self.ballView toDiameter:40.0];
            self.score = [NSNumber numberWithInt:0];
            [self.backButton setHidden:NO];
            [self reset];
        }
        else{
            if (self.isPlayerOnePlaying) {
                self.playerOneScoreLabel.text = [NSString stringWithFormat:@"Player One: %i", self.playerOneScore.intValue];
                [self.collisionBehavior removeItem:self.paddleView];
                self.snapBehavior.damping = 0.6;
                [self.dynamicAnimator addBehavior:self.snapBehavior];
                [UIView animateWithDuration:0.2 animations:^{
                    self.instructionsLabel.alpha = 1;
                }];
                [self setRoundedView:self.ballView toDiameter:40.0];
                self.isPlayerOnePlaying = NO;
                [self reset];
            }
            else{
                self.playerTwoScoreLabel.text = [NSString stringWithFormat:@"Player Two: %i", self.playerTwoScore.intValue];
                [self.collisionBehavior removeItem:self.paddleView];
                self.snapBehavior.damping = 0.6;
                [self.dynamicAnimator addBehavior:self.snapBehavior];
                [UIView animateWithDuration:0.2 animations:^{
                    self.instructionsLabel.alpha = 1;
                }];
                [self setRoundedView:self.ballView toDiameter:40.0];

                if (self.playerOneScore.intValue > self.playerTwoScore.intValue) {
                    self.instructionsLabel.text = @"Player One WINS!";
                    self.isGameOver = YES;
                }
                if (self.playerTwoScore.intValue > self.playerOneScore.intValue) {
                    self.instructionsLabel.text = @"Player Two WINS!";
                    self.isGameOver = YES;
                }
                if (self.playerOneScore.intValue == self.playerTwoScore.intValue) {
                    self.instructionsLabel.text = @"It's a TIE";
                    self.isGameOver = YES;
                }

                [self.backButton setHidden:NO];
            }
        }
    }
    [self.dynamicAnimator removeBehavior:self.pushBehavior];
    AudioServicesPlaySystemSound(beepCoinSound);
}

- (void) ballViewDidGetTapped:(BallView *)ballView
{
    if (!self.isTwoPlayerMode) {
        [self setUpPushBehaviorForBall];
    }
    if (self.isTwoPlayerMode && self.isPlayerOnePlaying) {
        [self setUpPushBehaviorForBall];
    } else if (self.isTwoPlayerMode && !self.isPlayerOnePlaying && self.isGameOver==NO){
        [self setUpPushBehaviorForBall];
    }
}

- (BOOL)shouldStartAgain
{
    NSMutableArray *blocksLeftArray = [[NSMutableArray alloc] init];
    for (id eachSubViewItem in self.view.subviews) {
        if ([eachSubViewItem isKindOfClass:[BlockView class]]) {
            [blocksLeftArray addObject:eachSubViewItem];
        }
    }
    if (blocksLeftArray.count == 0) {
        return YES;
    }
    return NO;
}


- (IBAction)dragPaddle:(UIPanGestureRecognizer *) panGestureRecognizer
{
    self.paddleView.center = CGPointMake([panGestureRecognizer locationInView:self.view].x, self.paddleView.center.y);
    [self.dynamicAnimator updateItemUsingCurrentState:self.paddleView];
}

- (void)reset
{
    for (BlockView *eachBlockView in self.arrayOfBlocks) {
        eachBlockView.backgroundColor = [UIColor yellowColor];
        if (eachBlockView.tag == 2) {
            eachBlockView.backgroundColor = [UIColor orangeColor];
            eachBlockView.hitLevel = [NSNumber numberWithInt:eachBlockView.tag];
        }
        if (eachBlockView.tag == 3) {
            eachBlockView.backgroundColor = [UIColor redColor];
            eachBlockView.hitLevel = [NSNumber numberWithInt:eachBlockView.tag];
        }
        [self.view addSubview:eachBlockView];

        [UIView animateWithDuration:0.4 animations:^{
            eachBlockView.alpha = 1.0;
            self.instructionsLabel.alpha = 1.0;
            [self setRoundedView:self.ballView toDiameter:40.0];
        }];

        [self.collisionBehavior addItem:eachBlockView];

    }
    [self.instructionsLabel sizeToFit];
    if (!self.isTwoPlayerMode)
    {
        self.instructionsLabel.text = @"Tap Ball to Continue";
        if (self.score == [NSNumber numberWithInt:0])
        {
            self.instructionsLabel.text = @"Tap Ball to Start New Game";
        }
    }
    else
    {
        if (self.isPlayerOnePlaying)
        {
            self.instructionsLabel.text = @"Player One - Tap Ball to Continue";
            if (self.playerOneScore == [NSNumber numberWithInt:0])
            {
                self.instructionsLabel.text = @"Player One - Tap Ball to Start";
            }
        }
        else
        {
            self.instructionsLabel.text = @"Player Two - Tap Ball to Continue";
            if (self.playerTwoScore == [NSNumber numberWithInt:0])
            {
                self.instructionsLabel.text = @"Player Two - Tap Ball to Start";
            }
            self.view.backgroundColor = [UIColor grayColor];
        }
    }
}


-(void)removeBlockFromSuperView:(BlockView *)collidedBlock{
    [collidedBlock removeFromSuperview];
    [self.collisionBehavior removeItem:collidedBlock];

    if ([self shouldStartAgain]) {
        [self.dynamicAnimator addBehavior:self.snapBehavior];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reset) userInfo:nil repeats:NO];
    }
}


-(void)setRoundedView:(UIView *)roundedView toDiameter:(float)newSize;
{
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (IBAction)returnToMenuButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.avPlayerBg stop];
}


-(void)setUpPushBehaviorForBall
{
    [self.collisionBehavior addItem:self.paddleView];
    [self.dynamicAnimator removeBehavior:self.snapBehavior];
    CGFloat randomVectorAmount = (arc4random_uniform(100) * 0.01)+0.1;
    CGFloat randomVectorAmountForY = (arc4random_uniform(100) * 0.01)-0.1;
    BOOL positiveOrNegative = arc4random_uniform(2);
    if (positiveOrNegative) {
        randomVectorAmount = -randomVectorAmount;
    }
    self.pushBehavior = [[UIPushBehavior alloc]initWithItems:@[self.ballView] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.pushDirection = CGVectorMake(randomVectorAmount,-randomVectorAmountForY);
    self.pushBehavior.active = YES;
    self.pushBehavior.magnitude = 0.8;
    [self.dynamicAnimator addBehavior:self.pushBehavior];
    [UIView animateWithDuration:0.2 animations:^{
        self.instructionsLabel.alpha = 0;
        [self setRoundedView:self.ballView toDiameter:15.0];
    }];
    if (self.score == [NSNumber numberWithInt:0]) {
        self.scoreLabel.text = @"0";
    }
    [self.backButton setHidden:YES];

}

@end
