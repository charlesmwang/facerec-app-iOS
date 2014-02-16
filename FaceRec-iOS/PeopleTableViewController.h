//
//  PeopleTableViewController.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import "FaceRecAPI.h"

@interface PeopleTableViewController : UITableViewController
@property (nonatomic, strong) NSArray* people;

@end
