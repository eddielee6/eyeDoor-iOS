//
//  ViewHistoryItemViewController.m
//  eyeDoor
//
//  Created by Eddie Lee on 11/04/2013.
//  Copyright (c) 2013 Eddie Lee. All rights reserved.
//

#import "ActivityDetailViewController.h"
#import "EyeDoorDataModel.h"

@interface ActivityDetailViewController ()
@property (weak, nonatomic) IBOutlet UIButton *removeEntryButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ActivityDetailViewController

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

-(void)load
{
    UIImage *buttonImage = [[UIImage imageNamed:@"orangeButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"orangeButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [self.removeEntryButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.removeEntryButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dark_leather.png"]];

    if(self.activityItem != nil) {
        static NSDateFormatter *format;
        format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"'at' HH:mm 'on' dd/MM/yy"];
        
        self.titleLabel.text = self.activityItem.message;
        self.dateLabel.text = [format stringFromDate:self.activityItem.dateReceived];

        if([self.activityItem.imagePath hasPrefix:@"http"]) {
            NSURL *imageURL = [NSURL URLWithString:self.activityItem.imagePath];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *image = [UIImage imageWithData:imageData];

            NSString *prefixString = @"SnapShot";
            NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
            NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@", prefixString, guid];
            NSString  *imagePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.jpeg", uniqueFileName]];
            [UIImageJPEGRepresentation(image, 1.0) writeToFile:imagePath atomically:YES];

            self.activityItem.imagePath = imagePath;

            NSManagedObjectContext *context = [[EyeDoorDataModel sharedDataModel] mainContext];
            if (context) {
                [context save:nil];
            }

            [self.imageView setImage:image];
        } else if([self.activityItem.imagePath length] > 0) {

            [self.imageView setImage:[UIImage imageWithContentsOfFile:self.activityItem.imagePath]];
        }
    }
}

- (IBAction)removeEntryButtonPressed:(id)sender
{
    [[EyeDoorDataModel.sharedDataModel mainContext] deleteObject:self.activityItem];
    
    NSError *saveError = nil;
    [[EyeDoorDataModel.sharedDataModel mainContext] save:&saveError];

    if (saveError) {
        NSLog(@"Delete activity item failed: %@", saveError.localizedDescription);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
