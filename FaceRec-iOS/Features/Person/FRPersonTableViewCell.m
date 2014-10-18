//
//  FRPersonTableViewCell.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 11/9/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRPersonTableViewCell.h"

NSString *const kFRPersonTableViewCellIdentifier = @"FRPersonTableViewCell";
NSString *const kFRPersonTableViewCellNibName = @"FRPersonTableViewCell";

@interface FRPersonTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end

@implementation FRPersonTableViewCell

- (void)updateName:(NSString *)name email:(NSString *)email
{
    self.nameLabel.text = name;
    self.emailLabel.text = email;
}

@end
