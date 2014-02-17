//
//  ServerListViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/17/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "ServerListViewController.h"

@interface ServerListViewController ()

@end

@implementation ServerListViewController

@synthesize managedObjectContext, servers, message, urlField, portField, appDelegate;

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
    
    
    //1
    appDelegate = [UIApplication sharedApplication].delegate;
    //2
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    
    message = [[UIAlertView alloc] initWithTitle:@"Enter Server Details"
                                                      message:nil
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Add", nil];
    
    [message setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    urlField = [message textFieldAtIndex:0];
    urlField.placeholder=@"URL";
    [urlField setText:@"https://"];
    
    portField = [message textFieldAtIndex:1];
    [portField setSecureTextEntry:NO];
    portField.placeholder=@"Port";
    [portField setText:@"80"];
    
    servers = [[NSMutableArray alloc] initWithArray:[appDelegate getServerList]];
    
    for( Server *s in servers)
    {
        if([s.selected boolValue])
        {

        }
    }
    
    [self.tableView reloadData];
    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [servers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    Server *server = [servers objectAtIndex:indexPath.row];
    if([server.selected boolValue])
    {
        [cell.textLabel setText:[NSString stringWithFormat:@"%@:%d    [x]", server.ip_address, [server.port intValue]]];
    }
    else
    {
        [cell.textLabel setText:[NSString stringWithFormat:@"%@:%d", server.ip_address, [server.port intValue]]];
    }
    // Configure the cell...
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    for(Server *s in servers)
    {
        s.selected = [NSNumber numberWithBool:NO];
        if([s isEqual:[servers objectAtIndex:indexPath.row]])
        {
            s.selected = [NSNumber numberWithBool:YES];
            FaceRecServer *faceServer = [FaceRecServer Server];
            faceServer.ip_address = s.ip_address;//Remove Https
            faceServer.port = [s.port intValue];
        }
    }
    [self.tableView reloadData];

}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Server *server = [servers objectAtIndex:indexPath.row];
        [self.managedObjectContext deleteObject:server];
        BOOL isSelectedServer = [server.selected boolValue];
        [servers removeObjectAtIndex:indexPath.row];
        if([servers count] && isSelectedServer)
        {
            Server *s = [servers objectAtIndex:0];
            s.selected = [NSNumber numberWithBool:YES];
            FaceRecServer *faceServer = [FaceRecServer Server];
            faceServer.ip_address = s.ip_address;//Remove Https
            faceServer.port = [s.port intValue];
        }
        NSError *error = nil;
        //Permanently remove object
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    [tableView reloadData];
}


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
- (IBAction)addServer:(id)sender {
    
    [message show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        for(Server *s in servers)
        {
            s.selected = [NSNumber numberWithBool:NO];
        }
        
        Server *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Server"
                                                          inManagedObjectContext:self.managedObjectContext];
        newEntry.ip_address = urlField.text;
        newEntry.port = [NSNumber numberWithInt:[portField.text intValue]];
        newEntry.selected = [NSNumber numberWithBool:YES];
        newEntry.secure = [NSNumber numberWithBool:YES];
        
        NSError *error;
        
        if(![self.managedObjectContext save:&error])
        {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        FaceRecServer *faceServer = [FaceRecServer Server];
        faceServer.ip_address = urlField.text;//Remove Https
        faceServer.port = [portField.text intValue];
        
        urlField.text = @"https://";
        
        [servers removeAllObjects];
        [servers addObjectsFromArray:[appDelegate getServerList]];
        [self.tableView reloadData];
    }
}

@end
