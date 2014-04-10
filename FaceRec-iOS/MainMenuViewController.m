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

@synthesize responseData, headerResponse, jsonResponse;

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
    responseData = [[NSMutableData alloc] init];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)logout:(id)sender {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:[[FaceRecServer Server] goToURL:@"/logout"]]];
    NSLog(@"%@",[[FaceRecServer Server] goToURL:@"/logout"]);
    request.timeoutInterval = 20.0;
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
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
    if([headerResponse statusCode] == 200)
    {
        [_keychain resetKeychainItem];
        [[User CurrentUser] logout];
        UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"iPhone_LoginStoryboard" bundle:nil];
        UIViewController *viewController = [loginStoryboard instantiateInitialViewController];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else
    {
        NSError *error;
        jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
        if(jsonResponse)
        {
        }
        else
        {
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

- (void) connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSLog(@"Checking Here");
    SecTrustRef trust = challenge.protectionSpace.serverTrust;
    NSURLCredential *cred;
    cred = [NSURLCredential credentialForTrust:trust];
    [challenge.sender useCredential:cred forAuthenticationChallenge:challenge];
}

@end
