//
//  FRPersonLabel.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 4/10/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FRPerson;

@interface FRPersonLabel : UILabel

@property (copy, nonatomic) FRPerson* person;

@end
