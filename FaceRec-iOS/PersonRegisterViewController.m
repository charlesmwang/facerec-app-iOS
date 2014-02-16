//
//  PersonRegisterViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "PersonRegisterViewController.h"

@interface PersonRegisterViewController ()

@end

@implementation PersonRegisterViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    //if([identifier isEqualToString:@"AddPerson"])
    {
        NSDictionary *response;
        NSError *error;
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"makoto117", @"username",
                                                                            [_firstname_field text], @"firstname",
                                                                            [_lastname_field text], @"lastname",
                                                                            [_email_field text], @"email",
                                                                            nil];
        [FaceRecAPI addPerson:dict response:&response error:&error];
        //if(!error && response)
        {
            return YES;
        }
            
    }
    return NO;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CaptureFaceViewController *viewController = [segue destinationViewController];
    viewController.person = [[Person alloc] initWithFirstName:[_firstname_field text] LastName:[_lastname_field text] Email:[_email_field text]];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
