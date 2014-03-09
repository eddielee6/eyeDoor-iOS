//
//  SettingsViewController.m
//  eyeDoor
//
//  Created by Eddie Lee on 22/02/2013.
//  Copyright (c) 2013 Eddie Lee. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsHelper.h"
#import "ActivityItem.h"
#import "EyeDoorDataModel.h"

@interface SettingsViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *urlTextArea;
@property (weak, nonatomic) IBOutlet UITextField *streamingPortTextArea;
@property (weak, nonatomic) IBOutlet UITextField *controlPortTextArea;
@property (weak, nonatomic) IBOutlet UITextView *deviceTokenLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *openConfigButton;
@property (weak, nonatomic) IBOutlet UIButton *clearAllButton;

@property (strong, nonatomic) SettingsHelper *settingsHelper;

@end

@implementation SettingsViewController

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
    self.settingsHelper = [[SettingsHelper alloc] init];
    self.urlTextArea.delegate = self;
    self.streamingPortTextArea.delegate = self;
    self.controlPortTextArea.delegate = self;

    UIImage *buttonImage = [[UIImage imageNamed:@"greyButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"greyButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];

    UIImage *redButtonImage = [[UIImage imageNamed:@"orangeButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *redButtonImageHighlight = [[UIImage imageNamed:@"orangeButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    [self.saveButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.saveButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [self.resetButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.resetButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [self.clearAllButton setBackgroundImage:redButtonImage forState:UIControlStateNormal];
    [self.clearAllButton setBackgroundImage:redButtonImageHighlight forState:UIControlStateHighlighted];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dark_leather.png"]];

    [self loadValues];
}

- (void)loadValues
{
    self.urlTextArea.text = [self.settingsHelper getURL];
    self.streamingPortTextArea.text = [NSString stringWithFormat:@"%@", [self.settingsHelper getStreamingPortNumber]];
    self.controlPortTextArea.text = [NSString stringWithFormat:@"%@", [self.settingsHelper getControlPortNumber]];
    self.deviceTokenLabel.text = [self.settingsHelper getDeviceToken];
}

- (IBAction)clearAllActivityButtonPressed:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear recent activity" message:@"Are you sure you want to clear all recent activity?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Clear", nil];
    [alert show];
}

- (IBAction)openConfigButtonPressed:(UIButton *)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@:%@", [self.settingsHelper getURL], [self.settingsHelper getControlPortNumber]]]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.urlTextArea resignFirstResponder];
    [self.streamingPortTextArea resignFirstResponder];
    [self.controlPortTextArea resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)saveButtonPressed:(UIButton *)sender
{
    [self.urlTextArea resignFirstResponder];
    [self.streamingPortTextArea resignFirstResponder];
    [self.controlPortTextArea resignFirstResponder];

    [self.settingsHelper setURL:self.urlTextArea.text];
    [self.settingsHelper setControlPortNumber:@(self.controlPortTextArea.text.intValue)];
    [self.settingsHelper setStreamingPortNumber:@(self.streamingPortTextArea.text.intValue)];
}

- (IBAction)resetDefaultsButtonPressed:(UIButton *)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset settings" message:@"Are you sure you want to restore the default settings?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reset", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if([alertView.title isEqualToString:@"Reset settings"]) {
            [self.settingsHelper setURL:nil];
            [self.settingsHelper setControlPortNumber:nil];
            [self.settingsHelper setStreamingPortNumber:nil];
            [self loadValues];
        } else if([alertView.title isEqualToString:@"Clear recent activity"]) {
            NSFetchRequest *fetchAllObjects = [[NSFetchRequest alloc] init];
            [fetchAllObjects setEntity:[NSEntityDescription entityForName:[ActivityItem entityName] inManagedObjectContext:[EyeDoorDataModel.sharedDataModel mainContext]]];
            [fetchAllObjects setIncludesPropertyValues:NO];

            NSError *error = nil;
            NSArray *allObjects = [[EyeDoorDataModel.sharedDataModel mainContext] executeFetchRequest:fetchAllObjects error:&error];

            if (error) {
                NSLog(@"Get all activity items failed: %@", error.localizedDescription);
            }

            for (NSManagedObject *object in allObjects) {
                [[EyeDoorDataModel.sharedDataModel mainContext] deleteObject:object];
            }

            NSError *saveError = nil;
            [[EyeDoorDataModel.sharedDataModel mainContext] save:&saveError];

            if (saveError) {
                NSLog(@"Delete all activity items failed: %@", saveError.localizedDescription);
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil];
        }
    }
}

@end
