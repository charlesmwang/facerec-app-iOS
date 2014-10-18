//
//  FRPersonTableViewCell.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 11/9/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kFRPersonTableViewCellIdentifier;
extern NSString *const kFRPersonTableViewCellNibName;

@interface FRPersonTableViewCell : UITableViewCell

- (void)updateName:(NSString *)name email:(NSString *)email;

@end
