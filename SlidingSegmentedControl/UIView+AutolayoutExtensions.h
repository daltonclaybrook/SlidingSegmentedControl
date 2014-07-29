//
//  UIView+AutolayoutExtensions.h
//  SlidingSegmentedControl
//
//  Created by Dalton Claybrook on 12/18/13.
//  Copyright (c) 2013 Space Factory Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AutolayoutExtensions)

- (void)constrainEdgesToSuperview;
- (void)constrainEdgesToSuperviewWithInsets:(UIEdgeInsets)insets;

@end
