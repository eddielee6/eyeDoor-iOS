//
//  AboutViewController.m
//  eyeDoor
//
//  Created by Eddie Lee on 11/04/2013.
//  Copyright (c) 2013 Eddie Lee. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    [self load];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self load];
}

- (void)load
{
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"about_background.png"]];
}

@end
