//
//  MainMenuViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/16/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "MainMenuViewController.h"

@interface MainMenuViewController ()

@property KeychainItemWrapper *keychain;

@end

@implementation MainMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"FaceRecApp" accessGroup:nil];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)logout:(id)sender {
    NSError* error;
    [FaceRecAPI logout:nil error:&error];
    //If Success
    {
        [_keychain resetKeychainItem];
        [[User CurrentUser] logout];
        UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"iPhone_LoginStoryboard" bundle:nil];
        UIViewController *viewController = [loginStoryboard instantiateInitialViewController];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    
}

@end
