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

@property (nonatomic, strong) NSMutableArray *filesArray;

- (id)initWithFilesystem:(DBFilesystem *)filesystem root:(DBPath *)root;
- (void)setFilesystem:(DBFilesystem *)filesystem andRootPath:(DBPath *)rootPath;

@end
