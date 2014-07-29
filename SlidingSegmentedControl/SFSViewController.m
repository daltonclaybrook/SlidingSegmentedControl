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
	
    self.segmentedControl.titles = @[@"These", @"Are", @"Options"];
}

#pragma mark - Actions;

- (IBAction)segmentedControlValueChanged:(id)sender
{
    NSString *selectedTitle = self.segmentedControl.titles[self.segmentedControl.selectedIndex];
    
    NSLog(@"title selected: %@", selectedTitle);
}

@end
