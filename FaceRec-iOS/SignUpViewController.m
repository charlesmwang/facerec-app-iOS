//
//  SignUpViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

@synthesize responseData, headerResponse, jsonResponse;

@synthesize scroller, username_field, email_field, password_field, cornfirmPassword_field, firstName_field, lastName_field;

@synthesize alertView, isSuccess;

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
    [scroller setScrollEnabled:YES];
    [scroller setContentSize:CGSizeMake(320, 600)];
    [scroller setContentOffset:CGPointMake(0,50) animated:NO];
    alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    isSuccess = NO;
    responseData = [[NSMutableData alloc] init];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [scroller setContentOffset:CGPointMake(0,0) animated:YES];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [scroller setContentOffset:CGPointMake(0,textField.center.y-140) animated:YES];
}
- (IBAction)createAccount:(id)sender {
    [self processAccountCreationProcess];
}

-(void) processAccountCreationProcess{
    isSuccess = NO;
    NSError *error;
    if([self validate_username:username_field.text error:&error]
       && [self validate_email:email_field.text error:&error]
        && [self validate_firstname:firstName_field.text error:&error]
         && [self validate_lastname:lastName_field.text error:&error]
          && [self validate_password:password_field.text confirm:cornfirmPassword_field.text error:&error]
       )
    {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        firstName_field.text, @"firstname",
                                        lastName_field.text, @"lastname",
                                        email_field.text, @"email",
                                        username_field.text, @"username",
                                        password_field.text, @"password",
                                        nil];
        NSError* error;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                        [NSURL URLWithString:[[FaceRecServer Server] goToURL:@"/signup"]]];
        request.timeoutInterval = 20.0;
        request.HTTPMethod = @"POST";
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        request.HTTPBody = jsonData;
        [[[NSURLConnection alloc] initWithRequest:request delegate:self] start];
        //Clear Memory
        [dict removeAllObjects];
        dict = nil;
        request = nil;
        jsonData = nil;
    }
    else
    {
        //Do error Handling
    }
}

//Add Validation
-(BOOL) validate_username:(NSString*) username error:(NSError**)error{
    return YES;
}

-(BOOL) validate_email:(NSString*) email error:(NSError**)error{
    return YES;
}

-(BOOL) validate_firstname:(NSString*) firstname error:(NSError**)error{
    return YES;
}

-(BOOL) validate_lastname:(NSString*) lastname error:(NSError**)error{
    return YES;
}

-(BOOL) validate_password:(NSString*) password confirm:(NSString*) confirm error:(NSError**)error{
    if([password isEqualToString:confirm])
    {
        return YES;
    }
    else
    {
        //Create Reason Here
        return NO;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    headerResponse = (NSHTTPURLResponse*) response;
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if([headerResponse statusCode] == 201)
    {
        isSuccess = YES;
        [alertView setTitle:@"Success"];
        [alertView setTitle:@"Account has been successfully created"];
        [alertView show];
    }
    else
    {
        isSuccess = NO;
        NSError *error;
        jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
        if(jsonResponse)
        {
            [alertView setTitle:@"Failed"];
            [alertView setMessage:[jsonResponse objectForKey:@"status"]];
            [alertView show];
        }
        else
        {
            [alertView setTitle:@"Failed"];
            [alertView setMessage:@"Unknown Error"];
            [alertView show];
        }

    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var

}

- (void) connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    SecTrustRef trust = challenge.protectionSpace.serverTrust;
    NSURLCredential *cred;
    cred = [NSURLCredential credentialForTrust:trust];
    [challenge.sender useCredential:cred forAuthenticationChallenge:challenge];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(isSuccess)
        [self.navigationController popViewControllerAnimated:YES];
    isSuccess = NO;
}

@end
