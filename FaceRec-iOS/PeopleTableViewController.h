//
//  PeopleTableViewController.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import "CaptureFaceViewController.h"
#import "FaceRecServer.h"
#import "User.h"

@interface PeopleTableViewController : UITableViewController <NSURLConnectionDelegate>
//@property (nonatomic, strong) NSMutableArray* people;

@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) NSHTTPURLResponse *headerResponse;
@property (strong, nonatomic) NSArray *jsonResponse;

@property (strong, nonatomic) NSArray *alphabetArray;

@property (strong, nonatomic) NSMutableDictionary *people;

@end
