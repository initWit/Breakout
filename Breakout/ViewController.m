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

@interface ViewController () <UICollisionBehaviorDelegate, BallViewDelegate>
@property (weak, nonatomic) IBOutlet PaddleView *paddleView;
@property (weak, nonatomic) IBOutlet BallView *ballView;
@property (strong, nonatomic) IBOutlet UILabel *instructionsLabel;
@property UIDynamicAnimator *dynamicAnimator;
@property UIPushBehavior *pushBehavior;
@property UICollisionBehavior *collisionBehavior;
@property UIDynamicItemBehavior *paddleDynamicBehavior;
@property UIDynamicItemBehavior *ballDynamicBehavior;
@property UISnapBehavior *snapBehavior;
@property NSMutableArray *arrayOfBlocks;
@property CAEmitterLayer *myEmitter;
@end

@implementation ViewController

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
            eachBlockView.backgroundColor = [UIColor blueColor];
        }
    }

    self.dynamicAnimator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];

    self.pushBehavior = [[UIPushBehavior alloc]initWithItems:@[self.ballView] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.pushDirection = CGVectorMake(0.5,0.5);
    self.pushBehavior.active = YES;
    self.pushBehavior.magnitude = 0.8;

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
//    self.paddleDynamicBehavior.elasticity = 1.0;
    [self.dynamicAnimator addBehavior:self.paddleDynamicBehavior];

    self.ballDynamicBehavior = [[UIDynamicItemBehavior alloc]initWithItems:@[self.ballView]];
    self.ballDynamicBehavior.allowsRotation = NO;
    self.ballDynamicBehavior.friction = 0.0;
    self.ballDynamicBehavior.elasticity = 1.0;
    self.ballDynamicBehavior.resistance = 0.0;
//    [self.ballDynamicBehavior addLinearVelocity:CGPointMake(0.4, 0.0) forItem:self.ballView];
    [self.dynamicAnimator addBehavior:self.ballDynamicBehavior];

    self.snapBehavior = [[UISnapBehavior alloc] initWithItem:self.ballView snapToPoint:self.view.center];

    self.paddleView.layer.cornerRadius = 10.0;

    [self setRoundedView:self.ballView toDiameter:40.0];

}


- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p
{
    if ([item1 isKindOfClass:[BlockView class]] || [item2 isKindOfClass:[BlockView class]])
    {
        BlockView *collidedBlock = (BlockView *)item1;
        if ([item2 isKindOfClass:[BlockView class]]) {
            collidedBlock = (BlockView *)item2;
        }

        collidedBlock.hitLevel = [NSNumber numberWithInt:[collidedBlock.hitLevel intValue]-1];

        if (collidedBlock.hitLevel.intValue == 1) {
            [UIView animateWithDuration:0.6 animations:^{
                collidedBlock.backgroundColor = [UIColor orangeColor];
            }];
        }
        else {
            [UIView animateWithDuration:0.6 animations:^{
                collidedBlock.backgroundColor = [UIColor whiteColor];
                collidedBlock.alpha = 0.0;
            }];
            [self performSelector:@selector(removeBlockFromSuperView:) withObject:collidedBlock afterDelay:0.6];
        }
    }
}


-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    if (p.y >= 565.0)
    {
//        [self.collisionBehavior removeItem:self.ballView];
        self.snapBehavior.damping = 0.6;
        [self.dynamicAnimator addBehavior:self.snapBehavior];
        [UIView animateWithDuration:0.2 animations:^{
            self.instructionsLabel.alpha = 1;
        }];
        [self setRoundedView:self.ballView toDiameter:40.0];
    }

    [self.dynamicAnimator removeBehavior:self.pushBehavior];
}

- (void) ballViewDidGetTapped:(BallView *)ballView
{

    [self.dynamicAnimator removeBehavior:self.snapBehavior];

    self.pushBehavior = [[UIPushBehavior alloc]initWithItems:@[self.ballView] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.pushDirection = CGVectorMake(0.1,0.5);
    self.pushBehavior.active = YES;
    self.pushBehavior.magnitude = 0.8;
    [self.dynamicAnimator addBehavior:self.pushBehavior];

    [UIView animateWithDuration:0.2 animations:^{
        self.instructionsLabel.alpha = 0;
        [self setRoundedView:self.ballView toDiameter:15.0];
    }];
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
        eachBlockView.backgroundColor = [UIColor orangeColor];
        if (eachBlockView.tag == 2) {
            eachBlockView.backgroundColor = [UIColor blueColor];
            eachBlockView.hitLevel = [NSNumber numberWithInt:2];
        }
        [self.view addSubview:eachBlockView];
        [UIView animateWithDuration:0.4 animations:^{
            eachBlockView.alpha = 1.0;
            self.instructionsLabel.alpha = 1.0;
            [self setRoundedView:self.ballView toDiameter:40.0];
        }];
        [self.collisionBehavior addItem:eachBlockView];
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

@end
