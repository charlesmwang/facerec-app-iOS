//
//  PeopleTableViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "PeopleTableViewController.h"

@interface PeopleTableViewController ()

@end

@implementation PeopleTableViewController

@synthesize people;

@synthesize responseData, headerResponse, jsonResponse;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    responseData = [[NSMutableData alloc] init];
    people = [NSMutableDictionary new];
    self.alphabetArray = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#123"];
    for(NSString* firstChar in self.alphabetArray)
    {
        [people setObject:[NSMutableArray new] forKey:[firstChar uppercaseString]];
    }
    [self loadPeopleList];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 27;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.alphabetArray objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [(NSMutableArray*)[people objectForKey:[self.alphabetArray objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@",[[people objectAtIndex:indexPath.row] fullname],[[people objectAtIndex:indexPath.row] email]];
    // Configure the cell...
    NSMutableArray* subPeople = (NSMutableArray*)[people objectForKey:[self.alphabetArray objectAtIndex:indexPath.section]];
    ((UILabel*)[cell viewWithTag:1]).text = [[subPeople objectAtIndex:indexPath.row] fullname];
    ((UILabel*)[cell viewWithTag:2]).text = [[subPeople objectAtIndex:indexPath.row] email];
    return cell;
}

- (void) loadPeopleList
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:[[FaceRecServer Server] goToURL:
                                  [NSString stringWithFormat:@"/people?%@=%@&%@=%@",
                                   @"username",[[User CurrentUser] username],
                                   @"token", [[User CurrentUser]access_token]]]]];
    request.timeoutInterval = 20.0;
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] start];
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


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Registration"])
    {
        
    }
    else if([segue.identifier isEqualToString:@"TableView"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        CaptureFaceViewController *viewController = segue.destinationViewController;
        NSMutableArray* subPeople = (NSMutableArray*)[people objectForKey:[self.alphabetArray objectAtIndex:indexPath.section]];
        viewController.person = [subPeople objectAtIndex:indexPath.row];
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
    if([headerResponse statusCode] == 200)
    {
        NSError *error;
        NSArray *t_response = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
        for(NSDictionary *d in t_response)
        {
            NSString* firstName = [d objectForKey:@"firstname"];
            NSString* firstChar = [[firstName substringToIndex:1] uppercaseString];
            NSLog(@"firstChar %@",firstChar);
            if([people objectForKey:[firstChar uppercaseString]])
            {
                [(NSMutableArray*)[people objectForKey:[firstChar uppercaseString]] addObject:[[Person alloc] initWithFirstName:[d objectForKey:@"firstname"] LastName:[d objectForKey:@"lastname"] Email:[d objectForKey:@"email"]]];
            }
            else
            {
                [(NSMutableArray*)[people objectForKey:@"#123"] addObject:[[Person alloc] initWithFirstName:[d objectForKey:@"firstname"] LastName:[d objectForKey:@"lastname"] Email:[d objectForKey:@"email"]]];
            }
        }
        t_response = nil;
        
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortUser"
                                                     ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        for(NSString* pKey in self.people.allKeys)
        {
            NSMutableArray* arr = (NSMutableArray*)[self.people objectForKey:pKey];
            NSArray *sortedArray;
            sortedArray = [arr sortedArrayUsingDescriptors:sortDescriptors];
            [self.people setObject:[NSMutableArray arrayWithArray:sortedArray] forKey:pKey];
        }
        [self.tableView reloadData];
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
