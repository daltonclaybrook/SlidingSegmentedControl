//
//  SFSViewController.m
//  SlidingSegmentedControl
//
//  Created by Dalton Claybrook on 7/29/14.
//  Copyright (c) 2014 Space Factory Studios. All rights reserved.
//

#import "SFSViewController.h"

@interface SFSViewController ()

@end

@implementation SFSViewController

#pragma mark - UIViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.segmentedControl.titles = @[@"Two", @"Pages"];
}

#pragma mark - Actions;

- (IBAction)segmentedControlValueChanged:(id)sender
{
    CGPoint offset = CGPointMake(self.segmentedControl.roundedSelectedIndex * CGRectGetWidth(self.scrollView.frame), 0.0f);
    
    [self.scrollView setContentOffset:offset animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat currentPage = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
    
    self.segmentedControl.selectedIndex = currentPage;
}

@end
