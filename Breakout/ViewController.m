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

@interface ViewController () <UICollisionBehaviorDelegate, BallViewDelegate>
@property (weak, nonatomic) IBOutlet PaddleView *paddleView;
@property (weak, nonatomic) IBOutlet BallView *ballView;
@property (weak, nonatomic) IBOutlet BlockView *blockView1;
@property (weak, nonatomic) IBOutlet BlockView *blockView2;
@property (weak, nonatomic) IBOutlet BlockView *blockView3;
@property (weak, nonatomic) IBOutlet BlockView *blockView4;
@property (weak, nonatomic) IBOutlet BlockView *blockView5;
@property (weak, nonatomic) IBOutlet BlockView *blockView6;
@property (weak, nonatomic) IBOutlet BlockView *blockView7;
@property (weak, nonatomic) IBOutlet BlockView *blockView8;

@property UIDynamicAnimator *dynamicAnimator;
@property UIPushBehavior *pushBehavior;
@property UICollisionBehavior *collisionBehavior;
@property UIDynamicItemBehavior *paddleDynamicBehavior;
@property UIDynamicItemBehavior *ballDynamicBehavior;
@property UISnapBehavior *snapBehavior;
@property UIGravityBehavior *gravityBehavior;
@property NSMutableArray *arrayOfBlocks;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.ballView.delegate = self;

    self.arrayOfBlocks = [[NSMutableArray alloc] initWithObjects:self.blockView1,
                          self.blockView2,
                          self.blockView3,
                          self.blockView4,
                          self.blockView5,
                          self.blockView6,
                          self.blockView7,
                          self.blockView8,nil];

    self.dynamicAnimator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    self.pushBehavior = [[UIPushBehavior alloc]initWithItems:@[self.ballView] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.pushDirection = CGVectorMake(0.3, 1);
    self.pushBehavior.active = YES;
    self.pushBehavior.magnitude = 0.3;
//    [self.dynamicAnimator addBehavior:self.pushBehavior];

    self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.ballView,self.paddleView,self.blockView1, self.blockView2,self.blockView3,self.blockView4, self.blockView5,self.blockView6,self.blockView7, self.blockView8]];
    self.collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
    self.collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    self.collisionBehavior.collisionDelegate = self;
    [self.dynamicAnimator addBehavior:self.collisionBehavior];

    self.paddleDynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.paddleView, self.blockView1,self.blockView2, self.blockView3,self.blockView4,self.blockView5,self.blockView6,self.blockView7,self.blockView8]];
    self.paddleDynamicBehavior.allowsRotation = NO;
    self.paddleDynamicBehavior.density = 10000;
    self.paddleDynamicBehavior.elasticity = 1.0;
    [self.dynamicAnimator addBehavior:self.paddleDynamicBehavior];

    self.ballDynamicBehavior = [[UIDynamicItemBehavior alloc]initWithItems:@[self.ballView]];
    self.ballDynamicBehavior.allowsRotation = YES;
    self.ballDynamicBehavior.friction = 0.0;
    self.ballDynamicBehavior.elasticity = 1.0;
    self.ballDynamicBehavior.resistance = 0.0;
    [self.dynamicAnimator addBehavior:self.ballDynamicBehavior];

    self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.ballView]];
    self.gravityBehavior.magnitude = 0.0;
    [self.dynamicAnimator addBehavior:self.gravityBehavior];
}


- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p
{
    if ([item1 isKindOfClass:[BallView class]] && [item2 isKindOfClass:[BlockView class]]) {
        BlockView *collidedBlock = (BlockView *)item2;

        [collidedBlock removeFromSuperview];
        [self.collisionBehavior removeItem:collidedBlock];

        if ([self shouldStartAgain]) {
            [self.dynamicAnimator addBehavior:self.snapBehavior];
            [self reset];
        }
    }
    [self.gravityBehavior removeItem:self.ballView];
}


-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    if (p.y >= 565.0) {
        CGPoint mainViewCenterPoint = self.view.center;
        self.snapBehavior = [[UISnapBehavior alloc] initWithItem:self.ballView snapToPoint:mainViewCenterPoint];
        [self.dynamicAnimator addBehavior:self.snapBehavior];

    }
}

- (void) ballViewDidGetTapped:(id)ballView
{
    [self.gravityBehavior addItem:self.ballView];
    self.gravityBehavior.magnitude = 0.3;
    self.gravityBehavior.gravityDirection = CGVectorMake(0.05, 1.0);
    [self.dynamicAnimator removeBehavior:self.snapBehavior];

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
        [self.view addSubview:eachBlockView];
        [self.collisionBehavior addItem:eachBlockView];
    }

}

@end
