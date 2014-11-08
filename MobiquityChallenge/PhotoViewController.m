//
//  PhotoViewController.m
//  MobiquityChallenge
//
//  Created by Chad Armstrong on 11/8/14.
//  Copyright (c) 2014 Chad Armstrong. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	[self setupInterface];
}

/**
 *  Setup the title and load the image into the image view
 */
- (void)setupInterface {
	
	self.navigationItem.title = self.imageFile.info.path.name;
	
	DBError *error = nil;
	NSData *imageData = [self.imageFile readData:&error];
	
	if (imageData != nil && error == noErr) {
		UIImage *image = [UIImage imageWithData:imageData];
		self.imageView.image = image;
	}
}

@end
