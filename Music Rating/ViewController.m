//
//  ViewController.m
//  Music Rating
//
//  Created by Genji on 2015/02/05.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

- (IBAction)openExtensionsPreferencePane:(id)sender;

@end

@implementation ViewController

- (IBAction)openExtensionsPreferencePane:(id)sender
{
  NSURL *aURL = [NSURL fileURLWithPath:@"/System/Library/PreferencePanes/Extensions.prefPane"];
  [[NSWorkspace sharedWorkspace] openURL:aURL];
}

@end
