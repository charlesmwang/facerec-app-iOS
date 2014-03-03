//
//  LoginViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property KeychainItemWrapper *keychain;

@end

@implementation LoginViewController

@synthesize responseData, headerResponse, jsonResponse, autologin, appDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    //Server Stuff
    appDelegate = [UIApplication sharedApplication].delegate;
    NSArray *servers = [appDelegate getServerList];
    FaceRecServer *server = [[FaceRecServer alloc] initWithIpAddress:@"" port:0];
    server = [FaceRecServer Server];
    for( Server *s in servers)
    {
        if([s.selected boolValue])
        {
            server.ip_address = s.ip_address;
            server.port = [s.port intValue];
            server.isUsingSSL = [s.secure boolValue];
            server.name = s.name;
        }
    }
    
    _keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"FaceRecApp" accessGroup:nil];
    NSString *username =[_keychain objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password =[_keychain objectForKey:(__bridge id)(kSecValueData)];
    _username_field.text =  username;
    _password_field.text =  password;
    autologin = NO;
    if([username isEqualToString:@""] && [password isEqualToString:@""])
    {
        autologin = NO;
    }
    else
        [self proceedLoginProcessWithUsername:username password:password];
    _alertView = [[UIAlertView alloc]initWithTitle:@"Title" message:@"Message" delegate:nil cancelButtonTitle:@"OK:" otherButtonTitles: nil];
    
    responseData = [[NSMutableData alloc] init];
    
    if(server)
    {
        _serverAddressLabel.text = server.url;
        _serverNameLabel.text = server.name;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) proceedLoginProcessWithUsername:(NSString*) username password:(NSString*) password{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:username, @"username", password, @"password", nil];
    NSError* error;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:[[FaceRecServer Server] goToURL:@"/login/"]]];
    request.timeoutInterval = 20.0;
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    request.HTTPBody = jsonData;
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] start];
}

- (IBAction)login:(id)sender {
    NSLog(@"Server: %@:%d",[[FaceRecServer Server] ip_address], [[FaceRecServer Server] port]);
    if([[appDelegate getServerList] count])
    {
        [self proceedLoginProcessWithUsername:_username_field.text password: _password_field.text];
    }
    else
    {
        _alertView.title = @"Failed to login!";
        _alertView.message = @"Please create a server before login.";
        [_alertView show];
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
        if(![_username_field.text isEqualToString:@""] && ![_password_field.text isEqualToString:@""])
        {
            [_keychain resetKeychainItem];
            [_keychain setObject:_username_field.text forKey:(__bridge id)(kSecAttrAccount)];
            [_keychain setObject:_password_field.text forKey:(__bridge id)(kSecValueData)];
        }
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"iPhone_MainStoryboard" bundle:nil];
        UIViewController *viewController = [mainStoryboard instantiateInitialViewController];
        [self presentViewController:viewController animated:!autologin completion:nil];
        NSError *error;
        jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
        User *user = [[User alloc] initWithUsername:[_keychain objectForKey:(__bridge id)(kSecAttrAccount)] token: [jsonResponse objectForKey:@"access_token"] expiration:[jsonResponse objectForKey:@"expiration"]];
        //Used to suppress warning
        [user none];
    }
    else
    {
        NSError *error;
        jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
        if(jsonResponse)
        {
            _alertView.title = @"Failed to login!";
            _alertView.message = [jsonResponse objectForKey:@"status"];
        }
        else
        {
            _alertView.title = @"Failed to login!";
            _alertView.message = @"Unknown Error";
        }
        [_alertView show];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    _alertView.title = @"Failed to login!";
    _alertView.message = @"Unknown Error";
    [_alertView show];
}

- (void) connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    SecTrustRef trust = challenge.protectionSpace.serverTrust;
    NSURLCredential *cred;
    cred = [NSURLCredential credentialForTrust:trust];
    [challenge.sender useCredential:cred forAuthenticationChallenge:challenge];
}

@end
