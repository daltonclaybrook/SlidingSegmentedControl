//
//  SFSViewController.h
//  SlidingSegmentedControl
//
//  Created by Dalton Claybrook on 7/29/14.
//  Copyright (c) 2014 Space Factory Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFSSlidingSegmentedControl.h"

@interface SFSViewController : UIViewController

@property (nonatomic, weak) IBOutlet SFSSlidingSegmentedControl *segmentedControl;

- (IBAction)segmentedControlValueChanged:(id)sender;

@end
