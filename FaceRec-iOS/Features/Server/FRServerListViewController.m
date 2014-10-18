//
//  ServerListViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/17/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRServerListViewController.h"
#import "FRServerUtilities.h"
#import "AppDelegate.h"
#import "Server.h"
#import "FaceRecServer.h"
#import "ServerInfoButton.h"
#import "FRServerCreationViewController.h"
#import "FRServerTableViewCell.h"

typedef NS_ENUM(NSUInteger, FRServersTableViewSection)
{
    FRServersTableViewSectionDefaultServer = 0,
    FRServersTableViewSectionOtherServers,
    FRServersTableViewSectionCount //This must be last
};

static NSString * const kFRServerListViewControllerIdentifer = @"FRServerListViewController";

@interface FRServerListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray* servers;
@property (copy, nonatomic) NSArray *defaultServer; //One server only

@property (nonatomic,strong) UITextField *urlField;
@property (nonatomic,strong) UITextField *portField;
@property (nonatomic,strong) AppDelegate *appDelegate;


@property (strong, nonatomic) Server *selectedServer;

-(void) refreshServerList;

@end

@implementation FRServerListViewController

+ (instancetype)viewController
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:kFRServerStoryboardID bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:kFRServerListViewControllerIdentifer];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    /*self.appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = self.appDelegate.managedObjectContext;
    self.servers = [[NSMutableArray alloc] initWithArray:[self.appDelegate getServerList]];
    [self refreshServerList];*/
}

-(void) refreshServerList
{
    [self.servers removeAllObjects];
    [self.servers addObjectsFromArray:[self.appDelegate getServerList]];
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
    return FRServersTableViewSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger numRows = 0;
    switch (section)
    {
        case FRServersTableViewSectionDefaultServer:
            numRows = 1;//Change
            break;
        case FRServersTableViewSectionOtherServers:
            numRows = [self.servers count];
            break;
        default:
            break;
    }
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    
    switch (indexPath.section)
    {
        case FRServersTableViewSectionDefaultServer:
        {
            FRServerTableViewCell *defaultServerCell = [tableView dequeueReusableCellWithIdentifier:kFRServerTableViewCellIdentifier forIndexPath:indexPath];
            cell = defaultServerCell;
            cell.selected = ([[tableView indexPathForSelectedRow] isEqual:indexPath]);
            break;
        }
        case FRServersTableViewSectionOtherServers:
        {
            FRServerTableViewCell *defaultServerCell = [tableView dequeueReusableCellWithIdentifier:kFRServerTableViewCellIdentifier forIndexPath:indexPath];
            cell = defaultServerCell;
            cell.selected = ([[tableView indexPathForSelectedRow] isEqual:indexPath]);
            break;
        }
        default:
            break;
    }
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    switch (indexPath.section)
    {
        case FRServersTableViewSectionDefaultServer:
            break;
        case FRServersTableViewSectionOtherServers:
            break;
        default:
            break;
    }
    
    for(Server *s in self.servers)
    {
        s.selected = [NSNumber numberWithBool:NO];
        if([s isEqual:[self.servers objectAtIndex:indexPath.row]])
        {
            s.selected = [NSNumber numberWithBool:YES];
            FaceRecServer *faceServer = [FaceRecServer Server];
            faceServer.ip_address = s.ip_address;//Remove Https
            faceServer.port = [s.port intValue];
            faceServer.isUsingSSL = [s.secure boolValue];
            faceServer.name = s.name;
        }
    }
    [self.tableView reloadData];

}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Server *server = [self.servers objectAtIndex:indexPath.row];
        [self.managedObjectContext deleteObject:server];
        BOOL isSelectedServer = [server.selected boolValue];
        [self.servers removeObjectAtIndex:indexPath.row];
        if([self.servers count] && isSelectedServer)
        {
            Server *s = [self.servers objectAtIndex:0];
            s.selected = [NSNumber numberWithBool:YES];
            FaceRecServer *faceServer = [FaceRecServer Server];
            faceServer.ip_address = s.ip_address;//Remove Https
            faceServer.port = [s.port intValue];
            faceServer.isUsingSSL = [s.secure boolValue];
            faceServer.name = s.name;
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
- (IBAction)openServerEditController:(id)sender {
    //ServerInfoButton *infoButton = (ServerInfoButton*) sender;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone_LoginStoryboard" bundle: nil];
    FRServerCreationViewController* vc = (FRServerCreationViewController*) [storyboard instantiateViewControllerWithIdentifier:@"ServerProfile"];
    //vc.serverToEdit = infoButton.server;
    //vc.editMode = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

@end
