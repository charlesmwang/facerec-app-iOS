//
//  Server.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/25/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Server : NSManagedObject

@property (nonatomic, retain) NSString * ip_address;
@property (nonatomic, retain) NSNumber * port;
@property (nonatomic, retain) NSNumber * secure;
@property (nonatomic, retain) NSNumber * selected;
@property (nonatomic, retain) NSString * name;

@end
