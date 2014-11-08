//
//  PhotoViewController.m
//  MobiquityChallenge
//
//  Created by Chad Armstrong on 11/8/14.
//  Copyright (c) 2014 Chad Armstrong. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

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

	UIBarButtonItem *shareButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareImage:)];
	self.navigationItem.rightBarButtonItem = shareButtonItem;
	self.navigationItem.title = self.imageFile.info.path.name;
	
	self.imageView.image = [self image];
}

/**
 *  Display the UIActivityViewController to share the image (i.e. Facebook, etc.)
 *
 *  @param sender The Share/Activity button
 */
- (IBAction)shareImage:(id)sender {
	
	UIImage *sharedImage = [self image];
	NSArray *activityItems = @[sharedImage];
	UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
	
	[self presentViewController:activityController animated:YES completion:nil];
}

/**
 *  Convert the data in the DBFile into a UIImage
 *
 *  @return UIImage representation of the DBFile
 */
- (UIImage *)image {
	
	DBError *error = nil;
	UIImage *image = nil;
	NSData *imageData = [self.imageFile readData:&error];
	
	if (imageData != nil && error == noErr) {
		UIImage *tempImage = [UIImage imageWithData:imageData];
		image = tempImage;
	}
	
	return image;
}

@end
