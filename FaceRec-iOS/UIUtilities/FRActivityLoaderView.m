//
//  FRActivityLoaderView.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 11/8/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRActivityLoaderView.h"


@interface FRActivityLoaderViewOwner : NSObject

@property (weak, nonatomic) IBOutlet FRActivityLoaderView *activityLoaderView;

@end

@implementation FRActivityLoaderViewOwner

@end

@interface FRActivityLoaderView ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation FRActivityLoaderView

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        FRActivityLoaderViewOwner *owner = [FRActivityLoaderViewOwner new];
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([FRActivityLoaderView class]) owner:owner options:nil];
        sharedInstance = owner.activityLoaderView;
    });
    return sharedInstance;
}

+ (void)presentInView:(UIView *)view
{
    FRActivityLoaderView *loaderView = [self sharedInstance];
    [loaderView.activityIndicator startAnimating];
    loaderView.frame = view.frame;
    [view addSubview:loaderView];
}

+ (void)dismiss
{
    FRActivityLoaderView *loaderView = [self sharedInstance];
    [loaderView.activityIndicator stopAnimating];
    [loaderView removeFromSuperview];
}

@end
