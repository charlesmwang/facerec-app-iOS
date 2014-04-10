//
//  RecognizedPersonTableViewController.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 4/10/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@interface RecognizedPersonTableViewController : UITableViewController

@property (nonatomic, strong) Person* person;


@property (nonatomic, strong) NSMutableArray* array;

@end
