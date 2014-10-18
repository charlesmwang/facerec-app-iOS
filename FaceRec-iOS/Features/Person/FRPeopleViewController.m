//
//  FRPeopleViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRPeopleViewController.h"
#import "FRPersonUtilities.h"
#import "FRPersonRegistrationViewController.h"
#import "FRPersonTableViewCell.h"
#import "FRPerson.h"
#import "FRCaptureFaceViewController.h"
#import "FRPersonNetworkOperation.h"

static NSString * const kFRPeopleViewControllerIdentifier = @"FRPeopleViewController";

@interface FRPeopleViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *addNewPersonButton;

@property (copy, nonatomic) NSArray *people;

@property (copy, nonatomic) NSDictionary *peopleDictionary;
@property (copy, nonatomic) NSArray *keyDictionary;

@property (copy, nonatomic) FRPerson *selectedPerson;

@end

@implementation FRPeopleViewController

#pragma mark - View Controller Instatiator

+ (instancetype)viewController
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:kFRPersonStoryboardID bundle:[NSBundle mainBundle]];
    return [sb instantiateViewControllerWithIdentifier:kFRPeopleViewControllerIdentifier];
}

#pragma mark - UIViewController Event Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:kFRPersonTableViewCellNibName
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kFRPersonTableViewCellIdentifier];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self mockData];
    //[self.tableView reloadData];
    [self retrievePeople];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numSections = 0;
    if(self.keyDictionary)
    {
        numSections = [self.keyDictionary count];
    }
    return numSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = self.keyDictionary[section];
    return [self.peopleDictionary[key] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.keyDictionary[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Put Assert
    NSString *key = self.keyDictionary[indexPath.section];
    NSArray *people = self.peopleDictionary[key];
    FRPerson *person = people[indexPath.row];
    FRPersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFRPersonTableViewCellIdentifier forIndexPath:indexPath];
    [cell updateName:[person fullname] email:person.email];
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = self.keyDictionary[indexPath.section];
    NSArray *people = self.peopleDictionary[key];
    self.selectedPerson = people[indexPath.row];
    
    [self presentViewController:[FRCaptureFaceViewController viewControllerWithPerson:self.selectedPerson]
                       animated:YES
                     completion:NULL];
}


#pragma mark - IBAction

- (IBAction)showAddNewPersonPage:(id)sender
{
    [self goToAddNewPersonPage];
}

#pragma mark - Helper

- (void)goToAddNewPersonPage
{
    [self.navigationController pushViewController:[FRPersonRegistrationViewController viewController] animated:YES];
}

- (void)sortKeyArrayInPeopleDictionary
{
    self.keyDictionary = [[self.peopleDictionary allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *k1, NSString *k2) {
        return [k1 compare:k2];
    }];
}

#pragma mark - Network Call

- (void)retrievePeople
{
    __weak FRPeopleViewController *weakSelf = self;
    [FRPersonNetworkOperation retrievePeopleWithSuccess:^(NSArray *people) {
        weakSelf.people = people;
        weakSelf.peopleDictionary = [FRPersonUtilities createDictionaryWithPeople:self.people
                                                                     sortMethod:FRPersonSortMethodByFirstName];
        [weakSelf sortKeyArrayInPeopleDictionary];
        [weakSelf.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - Mock

- (void)mockData
{
    self.people = @[
                    [[FRPerson alloc] initWithFirstName:@"Harris" lastName:@"Lavergne" email:@"vpy9i8xk3i@random.edu"],
                    [[FRPerson alloc] initWithFirstName:@"Fawn" lastName:@"Marlin" email:@"azisup43y5@random.edu"],
                    [[FRPerson alloc] initWithFirstName:@"Emerson" lastName:@"Brunett" email:@"oownop9l8w@random.edu"],
                    [[FRPerson alloc] initWithFirstName:@"Celia" lastName:@"Lanahan" email:@"fp45djs8je@random.edu"],
                    [[FRPerson alloc] initWithFirstName:@"Yan" lastName:@"Buss" email:@"yx8lf6oi4j@random.edu"],
                    [[FRPerson alloc] initWithFirstName:@"Frederic" lastName:@"Filippi" email:@"q0id1pqblu@random.edu"],
                    [[FRPerson alloc] initWithFirstName:@"Dann" lastName:@"Trujillo" email:@"zsjiv2hgsn@random.edu"],
                    [[FRPerson alloc] initWithFirstName:@"Elinor" lastName:@"Palafox" email:@"qz81t6a8zn@random.edu"],
                    ];
    
    self.peopleDictionary = [FRPersonUtilities createDictionaryWithPeople:self.people
                                                           sortMethod:FRPersonSortMethodByFirstName];
    
    [self sortKeyArrayInPeopleDictionary];
}

@end
