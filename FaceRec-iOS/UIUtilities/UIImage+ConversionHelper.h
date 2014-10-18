//
//  UIImage+ConversionHelper.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 11/10/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage(ConversionHelper)

+ (UIImage *)createUIImageFromCIImage:(CIImage *)ciImage;

@end
