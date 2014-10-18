//
//  FRPersonUtilities.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 11/9/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRPerson.h"

extern NSString * const kFRPersonStoryboardID;

@interface FRPersonUtilities : NSObject

+ (NSDictionary *)createDictionaryWithPeople:(NSArray *)array sortMethod:(FRPersonSortMethod)sortMethod;

@end
