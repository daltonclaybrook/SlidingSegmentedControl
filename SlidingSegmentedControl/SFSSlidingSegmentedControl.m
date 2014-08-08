//
//  SFSSlidingSegmentedControl.m
//  SlidingSegmentedControl
//
//  Created by Dalton Claybrook on 7/24/14.
//  Copyright (c) 2014 Space Factory Studios. All rights reserved.
//

#import "SFSSlidingSegmentedControl.h"
#import "UIView+AutolayoutExtensions.h"

static CGFloat const kOuterPadding = 6.0f;
static CGFloat const kAnimationDuration = 0.4f;

@interface SFSSlidingSegmentedControl ()

@property (nonatomic, strong) UIView *backgroundContainer;
@property (nonatomic, strong) UIView *foregroundContainer;

@property (nonatomic, copy) NSArray *backgroundLabels;
@property (nonatomic, copy) NSArray *foregroundLabels;

@property (nonatomic, strong) UIView *underlineView;

@property (nonatomic, strong) CALayer *maskLayer;
@property (nonatomic, strong) CALayer *labelMask;

@property (nonatomic, weak) UILabel *currentlyTappingForegroundLabel;
@property (nonatomic, weak) UILabel *currentlyTappingBackgroundLabel;

@property (nonatomic, strong) NSArray *underlineHeightConstraints;

@end

@implementation SFSSlidingSegmentedControl

#pragma mark - Initialzers

- (id)init
{
    self = [super init];
    if (self)
    {
        [self SFSSlidingSegmentedControlCommonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self SFSSlidingSegmentedControlCommonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self SFSSlidingSegmentedControlCommonInit];
    }
    return self;
}

- (instancetype)initWithTitles:(NSString *)titles
{
    self = [super init];
    if (self)
    {
        _titles = [titles copy];
        [self SFSSlidingSegmentedControlCommonInit];
    }
    return self;
}

- (void)SFSSlidingSegmentedControlCommonInit
{
    // Defaults
    _titleSpacing = 20.0f;
    _underlineHeight = 2.0f;
    _underlineSpacing = 4.0f;
    _selectedColor = [UIColor purpleColor];
    _unselectedColor = [UIColor lightGrayColor];
    _highlightedSelectedColor = [UIColor colorWithRed:0.3f green:0.0f blue:0.3f alpha:1.0f];
    _highlightedUnselectedColor = [UIColor darkGrayColor];
    
    // Initialization
    _titleFont = [UIFont systemFontOfSize:17.0f];
    self.backgroundColor = [UIColor clearColor];
    
    _backgroundContainer = [[UIView alloc] init];
    _backgroundContainer.userInteractionEnabled = NO;
    _backgroundContainer.backgroundColor = [UIColor clearColor];
    _backgroundContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_backgroundContainer];
    [_backgroundContainer constrainEdgesToSuperview];
    
    _foregroundContainer = [[UIView alloc] init];
    _foregroundContainer.userInteractionEnabled = NO;
    _foregroundContainer.backgroundColor = [UIColor clearColor];
    _foregroundContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_foregroundContainer];
    [_foregroundContainer constrainEdgesToSuperview];
    
    _underlineView = [[UIView alloc] init];
    _underlineView.userInteractionEnabled = NO;
    _underlineView.backgroundColor = self.selectedColor;
    _underlineView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.foregroundContainer addSubview:_underlineView];
    [self addConstraintsForUnderlineView];
    
    _maskLayer = [CALayer layer];
    _maskLayer.backgroundColor = [[UIColor clearColor] CGColor];
    self.foregroundContainer.layer.mask = _maskLayer;
    
    _labelMask = [CALayer layer];
    _labelMask.backgroundColor = [[UIColor greenColor] CGColor];
    [_maskLayer addSublayer:_labelMask];
    
    [self refreshTitles];
}

#pragma mark - Accessors

- (void)setSelectedIndex:(CGFloat)selectedIndex
{
    CGFloat adjustedIndex = MAX(MIN(selectedIndex, self.titles.count-1), 0.0f);
    if (fabsf(_selectedIndex - adjustedIndex) < FLT_EPSILON)
    {
        return;
    }
    _selectedIndex = adjustedIndex;
    
    [self setNeedsLayout];
}

- (NSUInteger)roundedSelectedIndex
{
    return roundf(self.selectedIndex);
}

- (void)setTitles:(NSArray *)titles
{
    if ([_titles isEqual:titles])
    {
        return;
    }
    _titles = titles;
    
    [self refreshTitles];
}

- (void)setTitleFont:(UIFont *)titleFont
{
    if ([_titleFont isEqual:titleFont])
    {
        return;
    }
    _titleFont = titleFont;
    
    [self refreshFont];
}

- (void)setTitleSpacing:(CGFloat)titleSpacing
{
    if (_titleSpacing == titleSpacing)
    {
        return;
    }
    _titleSpacing = titleSpacing;
    
    [self refreshTitles];
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    if ([_selectedColor isEqual:selectedColor])
    {
        return;
    }
    _selectedColor = selectedColor;
    
    [self refreshColors];
}

- (void)setUnselectedColor:(UIColor *)unselectedColor
{
    if ([_unselectedColor isEqual:unselectedColor])
    {
        return;
    }
    _unselectedColor = unselectedColor;
    
    [self refreshColors];
}

- (void)setUnderlineHeight:(CGFloat)underlineHeight
{
    if (_underlineHeight == underlineHeight)
    {
        return;
    }
    _underlineHeight = underlineHeight;
    
    [self refreshUnderlineHeightConstraints];
}

#pragma mark - UIControl

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self.foregroundLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        
        CGRect fullRect = [self fullTapRectSurroundingLabel:label];
        CGPoint location = [touch locationInView:self.foregroundContainer];
        if (CGRectContainsPoint(fullRect, location))
        {
            self.currentlyTappingForegroundLabel = label;
            self.currentlyTappingBackgroundLabel = self.backgroundLabels[idx];
            
            self.currentlyTappingForegroundLabel.highlighted = YES;
            self.currentlyTappingBackgroundLabel.highlighted = YES;
            
            *stop = YES;
        }
    }];
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (self.currentlyTappingForegroundLabel)
    {
        CGRect fullRect = [self fullTapRectSurroundingLabel:self.currentlyTappingForegroundLabel];
        CGPoint location = [touch locationInView:self.foregroundContainer];
        
        BOOL tapping = CGRectContainsPoint(fullRect, location);
        self.currentlyTappingBackgroundLabel.highlighted = tapping;
        self.currentlyTappingForegroundLabel.highlighted = tapping;
    }
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (self.currentlyTappingForegroundLabel)
    {
        self.currentlyTappingForegroundLabel.highlighted = NO;
        self.currentlyTappingBackgroundLabel.highlighted = NO;
        
        CGRect fullRect = [self fullTapRectSurroundingLabel:self.currentlyTappingForegroundLabel];
        CGPoint location = [touch locationInView:self.foregroundContainer];
        
        if (CGRectContainsPoint(fullRect, location))
        {
            NSUInteger index = [self.foregroundLabels indexOfObject:self.currentlyTappingForegroundLabel];
            if (index != NSNotFound && index != self.selectedIndex)
            {
                _selectedIndex = (CGFloat)index;
                [self updateMaskForSelectedIndexAnimated:YES];
                
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
        }
        
        self.currentlyTappingForegroundLabel = nil;
        self.currentlyTappingBackgroundLabel = nil;
    }
}

#pragma mark - UIView

- (CGSize)intrinsicContentSize
{
    if (!self.foregroundLabels.count)
    {
        return CGSizeZero;
    }
    
    CGFloat width = -self.titleSpacing + (kOuterPadding*2);
    for (UILabel *label in self.foregroundLabels)
    {
        width += [label intrinsicContentSize].width;
        width += self.titleSpacing;
    }
    width = MAX(0, width);
    
    CGFloat height = kOuterPadding;
    UILabel *label = [self.foregroundLabels firstObject];
    if (label)
    {
        height += [label intrinsicContentSize].height;
        height += self.underlineSpacing;
        height += self.underlineHeight;
    }
    
    return CGSizeMake(width, height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutIfNeeded];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    self.maskLayer.frame = self.foregroundContainer.bounds;
    [self updateMaskForSelectedIndexAnimated:NO];
    
    [CATransaction commit];
}

#pragma mark - Private

- (void)removeAllLabels
{
    NSArray *allLabels = [self.foregroundLabels arrayByAddingObjectsFromArray:self.backgroundLabels];
    for (UILabel *label in allLabels)
    {
        [label removeFromSuperview];
    }
    self.foregroundLabels = nil;
    self.backgroundLabels = nil;
    
    [self removeConstraints:self.constraints];
    [self.backgroundContainer constrainEdgesToSuperview];
    [self.foregroundContainer constrainEdgesToSuperview];
}

- (UILabel *)selectedLabelWithText:(NSString *)text
{
    UILabel *label = [[UILabel alloc] init];
    label.userInteractionEnabled = NO;
    label.backgroundColor = [UIColor clearColor];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = text;
    label.font = self.titleFont;
    
    return label;
}

- (UILabel *)unselectedLabelWithText:(NSString *)text
{
    UILabel *label = [[UILabel alloc] init];
    label.userInteractionEnabled = NO;
    label.backgroundColor = [UIColor clearColor];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = text;
    label.font = self.titleFont;
    
    return label;
}

- (void)updateMaskForSelectedIndexAnimated:(BOOL)animated
{
    if (!self.titles.count)
    {
        self.labelMask.frame = CGRectZero;
        return;
    }
    
    NSUInteger bottomIndex = (NSUInteger)floorf(self.selectedIndex);
    NSUInteger topIndex = (NSUInteger)ceilf(self.selectedIndex);
    
    UILabel *bottomLabel = self.foregroundLabels[bottomIndex];
    UILabel *topLabel = self.foregroundLabels[topIndex];
    CGFloat interpolation = self.selectedIndex - (CGFloat)bottomIndex;
    
    CGFloat widthDifference = CGRectGetWidth(topLabel.frame) - CGRectGetWidth(bottomLabel.frame);
    widthDifference *= interpolation;
    CGFloat maskWidth = CGRectGetWidth(bottomLabel.frame) + widthDifference;
    
    CGFloat originDifference = CGRectGetMinX(topLabel.frame) - CGRectGetMinX(bottomLabel.frame);
    originDifference *= interpolation;
    CGFloat maskXOrigin = CGRectGetMinX(bottomLabel.frame) + originDifference;
    
    CGFloat maskHeight = CGRectGetHeight(self.foregroundContainer.frame);
    CGRect oldLabelRect = self.labelMask.frame;
    CGRect newLabelRect = CGRectMake(maskXOrigin, 0.0, maskWidth, maskHeight);
    self.labelMask.frame = newLabelRect;
    
    if (animated)
    {
        [self animateLabelMaskFromFrame:oldLabelRect toFrame:newLabelRect];
    }
}

- (void)animateLabelMaskFromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"frame"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration = kAnimationDuration;
    animation.fromValue = [NSValue valueWithCGRect:fromFrame];
    animation.toValue = [NSValue valueWithCGRect:toFrame];
    
    [self.labelMask addAnimation:animation forKey:@"labelMaskAnimation"];
}

- (CGRect)fullTapRectSurroundingLabel:(UILabel *)label
{
    CGFloat xOrigin = MAX(CGRectGetMinX(label.frame) - (self.titleSpacing/2.0f), 0);
    CGFloat maxX = MIN(CGRectGetMaxX(label.frame) + (self.titleSpacing/2.0f), CGRectGetMaxX(self.foregroundContainer.bounds));
    CGFloat width = maxX - xOrigin;
    
    CGRect fullRect = CGRectMake(xOrigin, 0.0, width, CGRectGetHeight(self.foregroundContainer.frame));
    return fullRect;
}

#pragma mark - Refresh

- (void)refreshTitles
{
    [self removeAllLabels];
    
    NSMutableArray *foregroundLabels = [NSMutableArray array];
    NSMutableArray *backgroundLabels = [NSMutableArray array];
    
    CGFloat leftSpacing = kOuterPadding;
    NSLayoutAttribute attribute = NSLayoutAttributeLeft;
    UIView *previousForegroundView = self.foregroundContainer;
    UIView *previousBackgroundView = self.backgroundContainer;
    
    for (NSString *title in self.titles)
    {
        UILabel *foreLabel = [self selectedLabelWithText:title];
        [self.foregroundContainer addSubview:foreLabel];
        [foregroundLabels addObject:foreLabel];
        
        [self constrainLabel:foreLabel toPreviousView:previousForegroundView withPreviousViewAttribute:attribute withSpacing:leftSpacing];
        
        UILabel *backLabel = [self unselectedLabelWithText:title];
        [self.backgroundContainer addSubview:backLabel];
        [backgroundLabels addObject:backLabel];
        
        [self constrainLabel:backLabel toPreviousView:previousBackgroundView withPreviousViewAttribute:attribute withSpacing:leftSpacing];
        
        [self constrainForegroundLabelToUnderline:foreLabel];
        [self constrainLabelBottom:foreLabel toLabelBottom:backLabel];
        
        previousForegroundView = foreLabel;
        previousBackgroundView = backLabel;
        leftSpacing = self.titleSpacing;
        attribute = NSLayoutAttributeRight;
    }
    
    [self constrainViewToRight:previousForegroundView];
    [self constrainViewToRight:previousBackgroundView];
    
    self.foregroundLabels = [foregroundLabels copy];
    self.backgroundLabels = [backgroundLabels copy];
    
    [self refreshColors];
}

- (void)refreshFont
{
    for (UILabel *label in [self.foregroundLabels arrayByAddingObjectsFromArray:self.backgroundLabels])
    {
        label.font = self.titleFont;
    }
    [self invalidateIntrinsicContentSize];
}

- (void)refreshColors
{
    for (UILabel *label in self.foregroundLabels)
    {
        label.textColor = self.selectedColor;
        label.highlightedTextColor = self.highlightedSelectedColor;
    }
    
    for (UILabel *label in self.backgroundLabels)
    {
        label.textColor = self.unselectedColor;
        label.highlightedTextColor = self.highlightedUnselectedColor;
    }
    
    self.underlineView.backgroundColor = self.selectedColor;
}

- (void)refreshUnderlineHeightConstraints
{
    if (self.underlineHeightConstraints.count)
    {
        [self.underlineView removeConstraints:self.underlineHeightConstraints];
    }
    
    UIView *underlineView = self.underlineView;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(underlineView);
    
    NSString *format = [NSString stringWithFormat:@"V:[underlineView(==%f)]", self.underlineHeight];
    self.underlineHeightConstraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:bindings];
    
    [underlineView addConstraints:self.underlineHeightConstraints];
    [self invalidateIntrinsicContentSize];
}

#pragma mark - Constraints

- (void)addConstraintsForUnderlineView
{
    [self refreshUnderlineHeightConstraints];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.underlineView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.underlineView.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:kOuterPadding];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.underlineView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.underlineView.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.underlineView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.underlineView.superview attribute:NSLayoutAttributeRight multiplier:1.0 constant:-kOuterPadding];

    [self.underlineView.superview addConstraints:@[ leftConstraint, bottomConstraint, rightConstraint ]];
}

- (void)constrainLabel:(UILabel *)label toPreviousView:(UIView *)view withPreviousViewAttribute:(NSLayoutAttribute)attribute withSpacing:(CGFloat)spacing
{
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view attribute:attribute multiplier:1.0 constant:spacing];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:label.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:kOuterPadding];
    
    [label.superview addConstraints:@[ leftConstraint, topConstraint ]];
}

- (void)constrainForegroundLabelToUnderline:(UILabel *)label
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.underlineView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-self.underlineSpacing];
    
    [self.foregroundContainer addConstraint:constraint];
}

- (void)constrainLabelBottom:(UILabel *)label1 toLabelBottom:(UILabel *)label2
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:label2 attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    
    [self addConstraint:constraint];
}

- (void)constrainViewToRight:(UIView *)view
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeRight multiplier:1.0 constant:-kOuterPadding];
    
    [view.superview addConstraint:constraint];
}

@end
