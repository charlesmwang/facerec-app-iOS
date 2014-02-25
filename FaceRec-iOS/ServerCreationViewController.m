//
//  ServerCreationViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/25/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "ServerCreationViewController.h"

@interface ServerCreationViewController ()

@end

@implementation ServerCreationViewController

@synthesize nameField, hostField, sslSwitch, defaultSwitch, portField, appDelegate, managedObjectContext;

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
    
    portField.text = @"443";
    
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
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if(indexPath.row == 0)
    {
        static NSString *CellIdentifier = @"NameCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        nameField = (UITextField*)[cell viewWithTag:2];
    }
    else if(indexPath.row == 1)
    {
        static NSString *CellIdentifier = @"HostCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        hostField = (UITextField*)[cell viewWithTag:2];
    }
    else if(indexPath.row == 2)
    {
        static NSString *CellIdentifier = @"SSLCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        sslSwitch = (UISwitch*)[cell viewWithTag:2];
        [sslSwitch addTarget:self action:@selector(sslSwitchValueChanged) forControlEvents:UIControlEventValueChanged];
    }
    else if(indexPath.row == 3)
    {
        static NSString *CellIdentifier = @"PortCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        portField = (UITextField*)[cell viewWithTag:2];
    }
    else if(indexPath.row == 4)
    {
        static NSString *CellIdentifier = @"DefaultCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        defaultSwitch = (UISwitch*)[cell viewWithTag:2];
    }
    
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void) sslSwitchValueChanged
{
    if([sslSwitch isOn])
    {
        portField.text = @"443";
    }
    else
    {
        portField.text = @"80";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
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

-(IBAction)addServer:(id)sender
{

    
    Server *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Server"
                                                     inManagedObjectContext:self.managedObjectContext];
    

    if([sslSwitch isOn])
    {
        NSMutableArray* array = [[NSMutableArray alloc] initWithArray:[appDelegate getServerList]];
        
        for(Server *s in array)
        {
            s.selected = [NSNumber numberWithBool:NO];
        }
        
    }
    
    newEntry.secure = [NSNumber numberWithBool:[sslSwitch isOn]];
    newEntry.ip_address = hostField.text;
    newEntry.name = nameField.text;
    newEntry.port = [NSNumber numberWithInt:[portField.text intValue]];
    newEntry.selected = [NSNumber numberWithBool:[sslSwitch isOn]];
    
    
    NSError *error;
    
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    FaceRecServer *faceServer = [FaceRecServer Server];
    faceServer.ip_address = hostField.text;
    faceServer.port = [portField.text intValue];
    faceServer.isUsingSSL = [sslSwitch isOn];
    
    hostField.text = @"";
    nameField.text = @"";
    portField.text = @"";
    [defaultSwitch setOn:YES];
    [sslSwitch setOn:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

@end
