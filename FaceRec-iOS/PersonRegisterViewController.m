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

@synthesize responseData, headerResponse, jsonResponse;

@synthesize person, captureFaceViewController;

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
    responseData = [[NSMutableData alloc] init];
    captureFaceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CaptureMode"];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)registerPerson:(id)sender {
    [self proceedRegisterPersonProcess];
}

-(void) proceedRegisterPersonProcess
{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [[User CurrentUser] username], @"username",
                          [_firstname_field text], @"firstname",
                          [_lastname_field text], @"lastname",
                          [_email_field text], @"email",
                          nil];
    NSError* error;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:[[FaceRecServer Server] goToURL:@"/people/register"]]];
    request.timeoutInterval = 20.0;
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    request.HTTPBody = jsonData;
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] start];
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
        
        person = [[Person alloc] initWithFirstName:[_firstname_field text] LastName:[_lastname_field text] Email:[_email_field text]];
        captureFaceViewController.person = person;
        [self.navigationController pushViewController:captureFaceViewController animated:YES];
    }
    else
    {

    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}

- (void) connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    SecTrustRef trust = challenge.protectionSpace.serverTrust;
    NSURLCredential *cred;
    cred = [NSURLCredential credentialForTrust:trust];
    [challenge.sender useCredential:cred forAuthenticationChallenge:challenge];
}


@end
