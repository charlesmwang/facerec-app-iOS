//
//  FRFaceUtilities.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 11/9/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRFaceUtilities.h"

@implementation FRFaceUtilities

+ (NSString*)imageToBase64:(UIImage*)image
{
    return [UIImageJPEGRepresentation(image, 1.0) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

@end
