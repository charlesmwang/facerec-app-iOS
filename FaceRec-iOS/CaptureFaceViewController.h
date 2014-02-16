//
//  CaptureFaceViewController.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Person.h"

@interface CaptureFaceViewController : UIViewController <UIImagePickerControllerDelegate>

@property (nonatomic, strong) Person* person;


@end
