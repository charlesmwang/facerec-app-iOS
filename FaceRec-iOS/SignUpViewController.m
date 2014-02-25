//
//  SignUpViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/25/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

@synthesize username_field, email_field, password_field, confirmPassword_field, firstName_field, lastName_field, signupButton;
@synthesize alertView, isSuccess, responseData, jsonResponse, headerResponse;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    isSuccess = NO;
    responseData = [[NSMutableData alloc] init];
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.tableView addGestureRecognizer:tap];
}

-(void) dismissKeyboard
{
    [username_field resignFirstResponder];
    [email_field resignFirstResponder];
    [password_field resignFirstResponder];
    [confirmPassword_field resignFirstResponder];
    [firstName_field resignFirstResponder];
    [lastName_field resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([textField isEqual:firstName_field])
    {
        if([lastName_field.text isEqualToString:@""])
        {
            [lastName_field becomeFirstResponder];
        }
        else
        {
            [firstName_field resignFirstResponder];
        }
    }
    else if([textField isEqual:lastName_field])
    {
        if([email_field.text isEqualToString:@""])
        {
            [email_field becomeFirstResponder];
        }
        else
        {
            [lastName_field resignFirstResponder];
        }
    }
    else if([textField isEqual:email_field])
    {
        if([username_field.text isEqualToString:@""])
        {
            [username_field becomeFirstResponder];
        }
        else
        {
            [email_field resignFirstResponder];
        }
    }
    else if([textField isEqual:username_field])
    {
        if([password_field.text isEqualToString:@""])
        {
            [password_field becomeFirstResponder];
        }
        else
        {
            [username_field resignFirstResponder];
        }
    }
    else if([textField isEqual:password_field])
    {
        if([confirmPassword_field.text isEqualToString:@""])
        {
            [confirmPassword_field becomeFirstResponder];
        }
        else
        {
            [password_field resignFirstResponder];
        }
    }
    else if([textField isEqual:confirmPassword_field])
    {
        [confirmPassword_field resignFirstResponder];
    }
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(indexPath.row == 6) //Button
    {
        static NSString *CellIdentifier = @"SignUpCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        signupButton = (UIButton*) [cell viewWithTag:1];
        [signupButton addTarget:self action:@selector(createAccount:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        static NSString *CellIdentifier = @"FieldCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        UILabel* field_label = (UILabel*)[cell viewWithTag:1];
        if(indexPath.row == 0) //First Name
        {
            field_label.text = @"First Name";
            firstName_field = (UITextField*)[cell viewWithTag:2];
            //firstName_field.placeholder = field_label.text;
            firstName_field.delegate = self;
            firstName_field.returnKeyType = UIReturnKeyNext;
        }
        else if(indexPath.row == 1) //Last Name
        {
            field_label.text = @"Last Name";
            lastName_field = (UITextField*)[cell viewWithTag:2];
            //lastName_field.placeholder = field_label.text;
            lastName_field.delegate = self;
            lastName_field.returnKeyType = UIReturnKeyNext;
        }
        else if(indexPath.row == 2) //Email
        {
            field_label.text = @"Email";
            email_field = (UITextField*)[cell viewWithTag:2];
            //email_field.placeholder = field_label.text;
            email_field.delegate = self;
            email_field.returnKeyType = UIReturnKeyNext;
        }
        else if(indexPath.row == 3) //Username
        {
            field_label.text = @"Username";
            username_field = (UITextField*)[cell viewWithTag:2];
            //username_field.placeholder = field_label.text;
            username_field.delegate = self;
            username_field.returnKeyType = UIReturnKeyNext;
        }
        else if(indexPath.row == 4) //Password
        {
            field_label.text = @"Password";
            password_field = (UITextField*)[cell viewWithTag:2];
            //password_field.placeholder = field_label.text;
            password_field.delegate = self;
            password_field.secureTextEntry = YES;
            password_field.returnKeyType = UIReturnKeyNext;
        }
        else if(indexPath.row == 5) //Password Confirmation
        {
            field_label.text = @"Confirmation";
            confirmPassword_field = (UITextField*)[cell viewWithTag:2];
            //confirmPassword_field.placeholder = field_label.text;
            confirmPassword_field.delegate = self;
            confirmPassword_field.secureTextEntry = YES;
            confirmPassword_field.returnKeyType = UIReturnKeyDone;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;        
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (IBAction)createAccount:(id) sender{
    [self processAccountCreationProcess];
}

-(void) processAccountCreationProcess{
    isSuccess = NO;
    NSError *error;
    if([self validate_username:username_field.text error:&error]
       && [self validate_email:email_field.text error:&error]
       && [self validate_firstname:firstName_field.text error:&error]
       && [self validate_lastname:lastName_field.text error:&error]
       && [self validate_password:password_field.text confirm:confirmPassword_field.text error:&error]
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
