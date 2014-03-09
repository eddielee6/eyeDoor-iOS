//
//  eyeDoorViewController.m
//  eyeDoor
//
//  Created by Eddie Lee on 22/02/2013.
//  Copyright (c) 2013 Eddie Lee. All rights reserved.
//

#import "LiveFeedViewController.h"
#import "MotionJpegImageView.h"
#import "SettingsHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "ActivityItem.h"
#import "EyeDoorDataModel.h"
#import <AudioToolbox/AudioToolbox.h>
#import "ActivityDetailViewController.h"

@interface LiveFeedViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSFetchedResultsController *_fetchedResultsController;
}

@property (weak, nonatomic) IBOutlet UITableView *activityTable;
@property (weak, nonatomic) IBOutlet UIImageView *staticNoiseImageView;
@property (weak, nonatomic) IBOutlet MotionJpegImageView *mjpegView;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (strong, nonatomic) SettingsHelper *settingsHelper;

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, retain) UIWindow *window;

@end

@implementation LiveFeedViewController

@synthesize window = _window;

- (IBAction)saveCurrentFrame:(id)sender
{
    AudioServicesPlaySystemSound(1108);

    NSString *prefixString = @"SnapShot";
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@", prefixString, guid];
    NSString  *imagePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.jpeg", uniqueFileName]];
    [UIImageJPEGRepresentation(self.mjpegView.image, 1.0) writeToFile:imagePath atomically:YES];

    NSManagedObjectContext *context = [[EyeDoorDataModel sharedDataModel] mainContext];
    if (context) {
        ActivityItem *activiyItem = [ActivityItem insertInManagedObjectContext:context];

        activiyItem.dateReceived = [NSDate date];
        activiyItem.message = @"Snap shot taken";
        activiyItem.type = @"snapshot";
        activiyItem.imagePath = imagePath;

        [context save:nil];

        [self loadData];
    } else {
        NSLog(@"Failed to store new activity item");
    }
}

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

    self.staticNoiseImageView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"0000.jpg"],
                                         [UIImage imageNamed:@"0001.jpg"],
                                         [UIImage imageNamed:@"0002.jpg"],
                                         [UIImage imageNamed:@"0003.jpg"],
                                         [UIImage imageNamed:@"0004.jpg"],
                                         [UIImage imageNamed:@"0005.jpg"],
                                         [UIImage imageNamed:@"0006.jpg"],
                                                 nil];
    self.staticNoiseImageView.animationDuration = 0.8f;
    self.staticNoiseImageView.animationRepeatCount = 0;
    [self.staticNoiseImageView startAnimating];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dark_leather.png"]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newActivityItemAdded:) name:@"newActivityItemAdded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"reloadData" object:nil];

    [self loadIPCam];
    [self checkCameraStatus];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"activityDetail"]) {
        ActivityDetailViewController *vc = [segue destinationViewController];
        NSIndexPath *selectedRowIndexPath = [self.activityTable indexPathForSelectedRow];
        ActivityItem *selectedItem = [self.items objectAtIndex:selectedRowIndexPath.row];
        [vc setTitle:selectedItem.message];
        vc.activityItem = selectedItem;
    }
}

-(void)newActivityItemAdded:(NSNotification *) notification
{
    NSDictionary* userInfo = [notification userInfo];
    ActivityItem *activityItem = (ActivityItem *)[userInfo objectForKey:@"activityItem"];

    NSString *prefixString = [userInfo objectForKey:@"type"];
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@", prefixString, guid];
    NSString  *imagePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.jpeg", uniqueFileName]];
    [UIImageJPEGRepresentation(self.mjpegView.image, 1.0) writeToFile:imagePath atomically:YES];

    activityItem.imagePath = imagePath;
    NSError *saveError = nil;
    [[EyeDoorDataModel.sharedDataModel mainContext] save:&saveError];

    if (saveError) {
        NSLog(@"Failed to save image: %@", saveError.localizedDescription);
    }

    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)loadData
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ActivityItem.entityName];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateReceived" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];

    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                    managedObjectContext:[EyeDoorDataModel.sharedDataModel mainContext]
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    NSError *error = nil;
    [_fetchedResultsController performFetch:&error];

    self.items = _fetchedResultsController.fetchedObjects;
    [self.activityTable reloadData] ;

    if (error) {
        NSLog(@"Recent activity fetch failed: %@", error.localizedDescription);
    }
}

- (void)checkCameraStatus
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^ {
        sleep(0.5);
        dispatch_async(dispatch_get_main_queue(), ^ {
            if(![self.mjpegView isPlaying]) {
                [self loadIPCam];
            }
            self.takePhotoButton.hidden = ![self.mjpegView isPlaying];
            [self checkCameraStatus];
        });
    });
}

- (void)loadIPCam
{
    NSString *feedUrl = [NSString stringWithFormat:@"%@:%@", [self.settingsHelper getURL], [self.settingsHelper getStreamingPortNumber]];
    NSURL *url = [NSURL URLWithString:feedUrl];
    [self.mjpegView clear];
    self.mjpegView.url = url;
    [self.mjpegView play];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"historyCell";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    static NSDateFormatter *timeOnlyFormat;
    timeOnlyFormat = [[NSDateFormatter alloc] init];
    [timeOnlyFormat setDateFormat:@"HH:mm"];

    static NSDateFormatter *dayOnlyFormat;
    dayOnlyFormat = [[NSDateFormatter alloc] init];
    [dayOnlyFormat setDateFormat:@"EEEE"];

    static NSDateFormatter *dateOnlyFormat;
    dateOnlyFormat = [[NSDateFormatter alloc] init];
    [dateOnlyFormat setDateFormat:@"dd/MM/yy"];

    NSDate *receivedTime = ((ActivityItem *)self.items[indexPath.row]).dateReceived;
    if([receivedTime timeIntervalSinceNow] < -24*60*60*7) {
        cell.detailTextLabel.text = [dateOnlyFormat stringFromDate:receivedTime];
    } else if([receivedTime timeIntervalSinceNow] < -24*60*60) {
        cell.detailTextLabel.text = [dayOnlyFormat stringFromDate:receivedTime];
    } else {
        cell.detailTextLabel.text = [timeOnlyFormat stringFromDate:receivedTime];
    }
    

    cell.textLabel.text = ((ActivityItem *)self.items[indexPath.row]).message;
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    return cell;
}

@end
