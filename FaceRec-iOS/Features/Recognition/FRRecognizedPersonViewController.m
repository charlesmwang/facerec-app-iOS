//
//  RecognizedPersonViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 4/10/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRRecognizedPersonViewController.h"
#import "FRRecognitionUtilities.h"
#import "FRPerson.h"

typedef NS_ENUM(NSUInteger, RecognizedPersonTableViewSection) {
    RecognizedPersonTableViewSectionInfo = 0,
    RecognizedPersonTableViewSectionCount //This must be the last one
};

static NSString * const kFRRecognizedPersonViewControllerIdentifier = @"FRRecognizedPersonViewController";

@interface FRRecognizedPersonViewController () <UITableViewDataSource>

@property (copy, nonatomic)   FRPerson* person;
@property (strong, nonatomic) NSArray *array;
@property (copy, nonatomic)   UIImage *faceImage;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel     *fullNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *faceImageView;

@end

@implementation FRRecognizedPersonViewController

+ (instancetype)viewControllerWithPerson:(FRPerson *)person andfaceImage:(UIImage *)faceImage
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:kFRRecognitionStoryboardID bundle:[NSBundle mainBundle]];
    FRRecognizedPersonViewController *vc = [sb instantiateViewControllerWithIdentifier:kFRRecognizedPersonViewControllerIdentifier];
    vc.person = person;
    vc.faceImage = faceImage;
    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setup];
    
    //Trigger tableView load data
    self.tableView.dataSource = self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return RecognizedPersonTableViewSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger rowCount = 0;
    switch (section)
    {
        case RecognizedPersonTableViewSectionInfo:
        {
            rowCount = [self.array count];
            break;
        }
        default:
            break;
    }
    return rowCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.section)
    {
        case RecognizedPersonTableViewSectionInfo:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
            cell.textLabel.text = [self.array objectAtIndex:indexPath.row];
            break;
        }
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Setup

- (void)setup
{
    [self insertPersonDetailsInArray];
    self.faceImageView.image = self.faceImage;
}

- (void)insertPersonDetailsInArray
{
    self.array = @[[self.person fullname], self.person.email];
}

@end
