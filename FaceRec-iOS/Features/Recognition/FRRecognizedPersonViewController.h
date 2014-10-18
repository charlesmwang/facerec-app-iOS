//
//  RecognizedPersonViewController.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 4/10/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Person;

@interface FRRecognizedPersonViewController : UIViewController

+ (instancetype)viewControllerWithPerson:(Person *)person andfaceImage:(UIImage *)faceImage;

@end
