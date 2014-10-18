//
//  ServerCreationViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/25/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRServerCreationViewController.h"

@interface FRServerCreationViewController ()

@property (strong, nonatomic) UITextField *nameField;
@property (strong, nonatomic) UITextField *hostField;
@property (strong, nonatomic) UITextField *portField;
@property (strong, nonatomic) UISwitch *sslSwitch;
@property (strong, nonatomic) UISwitch *defaultSwitch;
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic,strong) AppDelegate *appDelegate;
@property (assign, nonatomic) BOOL editMode;
@property (assign, nonatomic) Server *serverToEdit;

@end

@implementation FRServerCreationViewController

@synthesize nameField, hostField, sslSwitch, defaultSwitch, portField, appDelegate, managedObjectContext, editMode, serverToEdit;

+ (instancetype)viewController
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:@""];
}

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
    
    if(!editMode)
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
    if(editMode)
        return 4;
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
        if(editMode)
            nameField.text = serverToEdit.name;
    }
    else if(indexPath.row == 1)
    {
        static NSString *CellIdentifier = @"HostCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        hostField = (UITextField*)[cell viewWithTag:2];
        if(editMode)
            hostField.text = serverToEdit.ip_address;
    }
    else if(indexPath.row == 2)
    {
        static NSString *CellIdentifier = @"SSLCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        sslSwitch = (UISwitch*)[cell viewWithTag:2];
        [sslSwitch addTarget:self action:@selector(sslSwitchValueChanged) forControlEvents:UIControlEventValueChanged];
        if(editMode)
            [sslSwitch setOn:[serverToEdit.secure boolValue]];
    }
    else if(indexPath.row == 3)
    {
        static NSString *CellIdentifier = @"PortCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        portField = (UITextField*)[cell viewWithTag:2];
        if(editMode)
            portField.text = [NSString stringWithFormat:@"%d",[serverToEdit.port intValue]];
    }
    else if(indexPath.row == 4) //In Edit Mode this will not be called
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

-(IBAction)addServer:(id)sender
{
    if(!editMode)
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
        faceServer.name = [nameField text];
        
        hostField.text = @"";
        nameField.text = @"";
        portField.text = @"";
        [defaultSwitch setOn:YES];
        [sslSwitch setOn:YES];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        NSMutableArray* array = [[NSMutableArray alloc] initWithArray:[appDelegate getServerList]];
        
        for(Server *s in array)
        {
            if([s isEqual:serverToEdit])
            {
                NSLog(@"%d",[portField.text intValue]);
                s.name = nameField.text;
                s.port = [NSNumber numberWithInt:[portField.text intValue]];
                s.ip_address = hostField.text;
                s.secure = [NSNumber numberWithBool:[sslSwitch isOn]];
                NSLog(@"Found");
            }
        }
        
        NSError *error;
        
        if(![self.managedObjectContext save:&error])
        {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
