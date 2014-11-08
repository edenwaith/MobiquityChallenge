//
//  ListFilesTableViewController.h
//  MobiquityChallenge
//
//  Created by Chad Armstrong on 11/7/14.
//  Copyright (c) 2014 Chad Armstrong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Dropbox/Dropbox.h>

@interface ListFilesTableViewController : UITableViewController

- (void)setFilesystem:(DBFilesystem *)filesystem andRootPath:(DBPath *)rootPath;

@end
