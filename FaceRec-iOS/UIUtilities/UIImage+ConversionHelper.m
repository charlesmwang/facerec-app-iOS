//
//  UIImage+ConversionHelper.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 11/10/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "UIImage+ConversionHelper.h"

@implementation UIImage(ConversionHelper)

+ (UIImage *)createUIImageFromCIImage:(CIImage *)ciImage
{
    
    @autoreleasepool {
        // finally!
        UIImage * returnImage;
        
        CGImageRef processedCGImage = [[CIContext contextWithOptions:nil] createCGImage:ciImage fromRect:[ciImage extent]];
        
        returnImage = [UIImage imageWithCGImage:processedCGImage];
        CGImageRelease(processedCGImage);
        
        processedCGImage = nil;
        
        return returnImage;
    }
}

@end
