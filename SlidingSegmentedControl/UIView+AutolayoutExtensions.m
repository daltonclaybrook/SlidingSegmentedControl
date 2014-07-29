//
//  UIView+AutolayoutExtensions.m
//  SlidingSegmentedControl
//
//  Created by Dalton Claybrook on 12/18/13.
//  Copyright (c) 2013 Space Factory Studios. All rights reserved.
//

#import "UIView+AutolayoutExtensions.h"

@implementation UIView (AutolayoutExtensions)

- (void)constrainEdgesToSuperview
{
    [self constrainEdgesToSuperviewWithInsets:UIEdgeInsetsZero];
}

- (void)constrainEdgesToSuperviewWithInsets:(UIEdgeInsets)insets
{
    NSAssert(self.superview, @"View: %@ must have a superview.", [self description]);
    if (!self.superview) return;
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:insets.top];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeRight multiplier:1.0 constant:-insets.right];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-insets.bottom];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:insets.left];
    
    [self.superview addConstraints:@[ topConstraint, rightConstraint, bottomConstraint, leftConstraint ]];
}

@end
