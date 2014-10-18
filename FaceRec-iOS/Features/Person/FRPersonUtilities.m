//
//  FRPersonUtilities.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 11/9/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRPersonUtilities.h"

NSString * const kFRPersonStoryboardID = @"FRPerson";

@implementation FRPersonUtilities

+ (NSDictionary *)createDictionaryWithPeople:(NSArray *)array sortMethod:(FRPersonSortMethod)sortMethod
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    NSArray *sortedArray = [self sortPeople:array sortMethod:sortMethod];
    
    for(FRPerson *person in sortedArray)
    {
        NSString *firstChar = [person extractFirstLetterWithSortMethod:sortMethod];
        
        NSMutableArray *mutableArray = dictionary[firstChar];
        
        if(!mutableArray)
        {
            mutableArray = [NSMutableArray new];
        }

        [mutableArray addObject:person];
        dictionary[firstChar] = mutableArray;
    }
    
    return dictionary;
}

+ (NSArray *)sortPeople:(NSArray *)people sortMethod:(FRPersonSortMethod)sortMethod
{
    NSArray *sortedArray = [people sortedArrayUsingComparator:^NSComparisonResult(FRPerson *p1, FRPerson *p2)
    {
        return [p1 compare:p2 sortMethod:sortMethod];
    }];
    return sortedArray;
}

@end
