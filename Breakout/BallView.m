//
//  BallView.m
//  Breakout
//
//  Created by Timothy P. Hennig on 5/22/14.
//  Copyright (c) 2014 PHMobileMakers. All rights reserved.
//

#import "BallView.h"

@implementation BallView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onBallViewTapped:)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

-(void) onBallViewTapped:(id)sender{
    [self.delegate ballViewDidGetTapped:self];
}

@end
