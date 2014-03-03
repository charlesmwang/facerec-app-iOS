//
//  ServerCreationViewController.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/25/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Server.h"
#import "FaceRecServer.h"
#import "AppDelegate.h"
#import "ServerListViewController.h"


@interface ServerCreationViewController : UITableViewController

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
