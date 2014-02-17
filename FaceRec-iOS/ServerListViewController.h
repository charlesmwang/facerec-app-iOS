//
//  ServerListViewController.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/17/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Server.h"
#import "FaceRecServer.h"

@interface ServerListViewController : UITableViewController <UIAlertViewDelegate>

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

@property (nonatomic,strong) NSMutableArray* servers;

@property (nonatomic,strong) UIAlertView *message;

@property (nonatomic,strong) UITextField *urlField;

@property (nonatomic,strong) UITextField *portField;

@property (nonatomic,strong) AppDelegate *appDelegate;
@end
