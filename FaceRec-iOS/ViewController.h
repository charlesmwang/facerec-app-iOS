//
//  ViewController.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 1/29/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketIOPacket.h"
#import "SocketIO.h"
#import "FaceRecServer.h"

@interface ViewController : UIViewController <SocketIODelegate>

@property(nonatomic, strong) SocketIO* socket;

@end
