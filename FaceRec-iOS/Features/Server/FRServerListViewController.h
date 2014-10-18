//
//  FRServerListViewController.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/17/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FRServerListViewControllerDelegate;

@class Server;

@interface FRServerListViewController : UIViewController

+ (instancetype)viewController;

@property (weak, nonatomic) id<FRServerListViewControllerDelegate> delegate;

@end

@protocol FRServerListViewControllerDelegate <NSObject>

@required

- (void) serverList:(FRServerListViewController *)viewController selectedServer:(Server *)server;

@end