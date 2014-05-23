//
//  BallView.h
//  Breakout
//
//  Created by Timothy P. Hennig on 5/22/14.
//  Copyright (c) 2014 PHMobileMakers. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BallViewDelegate
- (void) ballViewDidGetTapped:(id)ballView;
@end

@interface BallView : UIView
@property id<BallViewDelegate> delegate;
@end
