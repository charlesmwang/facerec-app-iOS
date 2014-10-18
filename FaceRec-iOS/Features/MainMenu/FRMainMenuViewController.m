//
//  MainMenuViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/16/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRMainMenuViewController.h"
#import "FRLoginViewController.h"
#import "FRMainMenuNetworkOperation.h"
#import "FRPeopleViewController.h"
#import "FRUser.h"

static NSString * const kFRMainMenuStoryboardID= @"FRMainMenu";
static NSString * const kFRMainMenuViewControllerIdentifier = @"FRMainMenuViewController";

@interface FRMainMenuViewController ()

@end

@implementation FRMainMenuViewController

#pragma mark - View Controller Instantiator

+ (instancetype)viewController
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:kFRMainMenuStoryboardID bundle:[NSBundle mainBundle]];
    return [sb instantiateViewControllerWithIdentifier:kFRMainMenuViewControllerIdentifier];
}

#pragma mark - UIViewController Event Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - IBAction

- (IBAction)showRecognizeScreen:(id)sender
{
    
}

- (IBAction)showAddFaceScreen:(id)sender
{
    [self.navigationController pushViewController:[FRPeopleViewController viewController] animated:YES];
}

- (IBAction)showSettingsScreen:(id)sender
{
    
}

- (IBAction)logout:(id)sender
{
    [self performLogout];
}

#pragma mark - Logout

- (void)performLogout
{
    __weak FRMainMenuViewController *weakSelf = self;
    [FRMainMenuNetworkOperation performLogoutWithSuccess:^{
        [[FRUser sharedInstance] logout];
    } failure:^(NSError *error) {
        //Show Alert
    }];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[FRLoginViewController viewController]];
    [weakSelf.navigationController presentViewController:navController animated:YES completion:NULL];
}

@end
