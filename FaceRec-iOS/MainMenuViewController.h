//
//  MainMenuViewController.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/16/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceRecAPI.h"
#import "KeychainItemWrapper.h"
#import "User.h"

@interface MainMenuViewController : UIViewController <NSURLConnectionDelegate>

@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) NSHTTPURLResponse *headerResponse;
@property (strong, nonatomic) NSDictionary *jsonResponse;

@end
