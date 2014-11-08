//
//  PhotoViewController.h
//  MobiquityChallenge
//
//  Created by Chad Armstrong on 11/8/14.
//  Copyright (c) 2014 Chad Armstrong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Dropbox/Dropbox.h>

@interface PhotoViewController : UIViewController

@property (nonatomic, strong) DBFile *imageFile;

@end
