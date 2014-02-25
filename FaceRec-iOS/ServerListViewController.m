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
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    servers = [[NSMutableArray alloc] initWithArray:[appDelegate getServerList]];
    [self refreshServerList];
}

-(void) refreshServerList
{
    [servers removeAllObjects];
    [servers addObjectsFromArray:[appDelegate getServerList]];
    [self.tableView reloadData];
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
    static NSString *CellIdentifier = @"ServerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    Server *server = [servers objectAtIndex:indexPath.row];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
    UILabel *name_label = (UILabel*)[cell viewWithTag:2];
    UILabel *address_label = (UILabel*)[cell viewWithTag:3];
    name_label.text = server.name;
    if([server.selected boolValue])
    {
        imageView.hidden = NO;
        if([server.secure boolValue])
            [address_label setText:[NSString stringWithFormat:@"https://%@:%d", server.ip_address, [server.port intValue]]];
        else
            [address_label setText:[NSString stringWithFormat:@"http://%@:%d", server.ip_address, [server.port intValue]]];
    }
    else
    {
        imageView.hidden = YES;
        if([server.secure boolValue])
            [address_label setText:[NSString stringWithFormat:@"https://%@:%d", server.ip_address, [server.port intValue]]];
        else
            [address_label setText:[NSString stringWithFormat:@"http://%@:%d", server.ip_address, [server.port intValue]]];
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
            faceServer.isUsingSSL = [s.secure boolValue];
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
            faceServer.isUsingSSL = [s.secure boolValue];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (IBAction)addServer:(id)sender {
    
    [message show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        //Check if the textfield has http in the url
        if([urlField.text rangeOfString:@"https://"].location == NSNotFound &&
           [urlField.text rangeOfString:@"http://"].location == NSNotFound)
        {
            //Display Error Message;
            return;
        }
        
        for(Server *s in servers)
        {
            s.selected = [NSNumber numberWithBool:NO];
        }
        
        NSString *ip;
        BOOL isHttps = NO;
        
        Server *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Server"
                                                         inManagedObjectContext:self.managedObjectContext];
        
        if([urlField.text rangeOfString:@"https://"].location == NSNotFound)
        {
            newEntry.secure = [NSNumber numberWithBool:NO];
            newEntry.ip_address = [urlField.text substringFromIndex:7];
            ip = [urlField.text substringFromIndex:7];
        }
        else
        {
            isHttps = YES;
            newEntry.secure = [NSNumber numberWithBool:YES];
            newEntry.ip_address = [urlField.text substringFromIndex:8];
            ip = [urlField.text substringFromIndex:8];
        }
        
        newEntry.name = @"Test Entry";
        newEntry.port = [NSNumber numberWithInt:[portField.text intValue]];
        newEntry.selected = [NSNumber numberWithBool:YES];
        
        NSError *error;
        
        if(![self.managedObjectContext save:&error])
        {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        FaceRecServer *faceServer = [FaceRecServer Server];
        faceServer.ip_address = ip;//Remove Https
        faceServer.port = [portField.text intValue];
        faceServer.isUsingSSL = isHttps;
        
        urlField.text = @"https://";
        
        [servers removeAllObjects];
        [servers addObjectsFromArray:[appDelegate getServerList]];
        [self.tableView reloadData];
    }
}

@end
