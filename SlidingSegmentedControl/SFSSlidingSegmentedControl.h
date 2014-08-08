//
//  SFSSlidingSegmentedControl.h
//  SlidingSegmentedControl
//
//  Created by Dalton Claybrook on 7/24/14.
//  Copyright (c) 2014 Space Factory Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFSSlidingSegmentedControl : UIControl

@property (nonatomic, copy) NSArray *titles;
@property (nonatomic, assign) CGFloat titleSpacing;
@property (nonatomic, assign) CGFloat underlineHeight;
@property (nonatomic, assign) CGFloat underlineSpacing;

@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIColor *unselectedColor;
@property (nonatomic, strong) UIColor *highlightedSelectedColor;
@property (nonatomic, strong) UIColor *highlightedUnselectedColor;

@property (nonatomic, assign) CGFloat selectedIndex;
@property (nonatomic, assign, readonly) NSUInteger roundedSelectedIndex;

// Initialziers
- (instancetype)initWithTitles:(NSArray *)titles;

@end
