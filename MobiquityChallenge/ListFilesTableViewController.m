//
//  ListFilesTableViewController.m
//  MobiquityChallenge
//
//  Created by Chad Armstrong on 11/7/14.
//  Copyright (c) 2014 Chad Armstrong. All rights reserved.
//

#import "ListFilesTableViewController.h"



@interface ListFilesTableViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) DBFilesystem *filesystem;
@property (nonatomic, strong) DBPath *rootPath;

@end

@implementation ListFilesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    self.navigationItem.title = @"Mobiquity";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
	[self reload];
}

#pragma mark - Custom Class Methods

- (id)initWithFilesystem:(DBFilesystem *)filesystem root:(DBPath *)root {
    
    if ((self = [super init])) {
        self.filesystem = filesystem;
        self.rootPath = root;
        self.navigationItem.title = [root isEqual:[DBPath root]] ? @"Dropbox" : [root name];
    }
    
    return self;
}

- (NSMutableArray *)filesArray {
    // Initialize the array, if necessary
    if (_filesArray == nil) {
        _filesArray = [[NSMutableArray alloc] init];
    }
    
    return _filesArray;
}

- (BOOL)accountIsLinked {
    return [[DBAccountManager sharedManager].linkedAccounts count] > 0;
}

- (void)setFilesystem:(DBFilesystem *)filesystem andRootPath:(DBPath *)rootPath {
    _filesystem = filesystem;
    _rootPath = rootPath;
    
    [self loadFiles];
}

//NSInteger sortFileInfos(id obj1, id obj2, void *ctx) {
//    return [[obj1 path] compare:[obj2 path]];
//}

- (void)loadFiles {
//    if (_loadingFiles) return;
//    _loadingFiles = YES;
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
//        NSArray *immContents = [_filesystem listFolder:_root error:nil];
//        NSMutableArray *mContents = [NSMutableArray arrayWithArray:immContents];
//        [mContents sortUsingFunction:sortFileInfos context:NULL];
//        dispatch_async(dispatch_get_main_queue(), ^() {
//            self.contents = mContents;
//            _loadingFiles = NO;
//            [self reload];
//        });
//    });
    
    DBError *err = nil;
	
	if (self.filesArray != nil && [self.filesArray count] > 0) {
		[self.filesArray removeAllObjects];
	}
	
    self.filesArray = (NSMutableArray *)[self.filesystem listFolder:self.rootPath error:&err];
    
    if (err != noErr) {
        NSLog(@"Error retrieving files: %@ (%d)", [err localizedDescription], (int)[err dbErrorCode]);
    } else {
		[self reload];
    }
    
}

- (void)reload {
	
	if ([self accountIsLinked] == YES) {
		UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];
		self.navigationItem.rightBarButtonItem = addButtonItem;
	} else {
		self.navigationItem.rightBarButtonItem = nil;
	}
	
	[self.tableView reloadData];
}

#pragma mark -

- (IBAction)addNewItem:(id)sender {
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
											   destructiveButtonTitle:nil
													otherButtonTitles:NSLocalizedString(@"Add New Photo", nil), NSLocalizedString(@"Add Existing Photo", nil), NSLocalizedString(@"Add Note", nil), nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSLog(@"buttonIndex: %ld", (long)buttonIndex);
	
	if (buttonIndex != actionSheet.cancelButtonIndex) {
		if (buttonIndex == 0) { // Add New Photo
			[self addNewPhoto];
		} else if (buttonIndex == 1) { // Add Existing Photo
			[self addExistingPhoto];
		} else if (buttonIndex == 2) { // Add Note
			[self addNewNote];
		}
	}
}

#pragma mark - Add New Item Methods

- (void)addNewPhoto {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", nil)
															  message:NSLocalizedString(@"This device doesn't have a camera.", nil)
															 delegate:nil
													cancelButtonTitle:NSLocalizedString(@"OK", nil)
													otherButtonTitles: nil];
		
		[alert show];
		
	} else {
		
		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
		
		imagePicker.delegate = self;
		imagePicker.allowsEditing = YES;
		imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		
		[self presentViewController:imagePicker animated:YES completion:nil];
	}
}

- (void)addExistingPhoto {
	
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	
	imagePicker.delegate = self;
	imagePicker.allowsEditing = YES;
	imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
	[self presentViewController:imagePicker animated:YES completion:nil];
	
}

- (void)addNewNote {
	
}

#pragma mark - UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
	NSString *fileName = [NSString stringWithFormat:@"%d.png", (int)[self.filesArray count]];
	
	DBError *error = nil;
	DBPath *path = [self.rootPath childPath:fileName];
	DBFile *file = [self.filesystem createFile:path error:&error];
	
	if (error != noErr) {
		NSLog(@"Error creating file: %@", [error localizedDescription]);
	} else {
		error = nil;
		[file writeData:UIImagePNGRepresentation(editedImage) error:&error];
		
		if (error != noErr) {
			NSLog(@"Error writing to file: %@", [error localizedDescription]);
		}
	}
	
	[picker dismissViewControllerAnimated:YES completion:nil];
	
	[self loadFiles];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

	[picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

/**
 *  If a Dropbox account has not been linked up yet, only show a single row in one section
 *  which says "Link to Dropbox"
 *
 *  @param tableView The main tableview
 *
 *  @return Count of number of sections to display
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return ([self.filesArray count] > 0) ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    if ([self.filesArray count] > 0 && section == 0) {
        return [self.filesArray count];
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
    if ([self.filesArray count] > 0 && indexPath.section == 0) {
		
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
		}
		
        DBFileInfo *fileInfo = [self.filesArray objectAtIndex:indexPath.row];
        cell.textLabel.text = fileInfo.path.name;
		cell.textLabel.textAlignment = NSTextAlignmentLeft;
		
		if ([fileInfo thumbExists] == YES) {

			DBError *error = nil;
			DBFile *thumbNail = [self.filesystem openThumbnail:fileInfo.path ofSize:DBThumbSizeS inFormat:DBThumbFormatPNG error:&error];
			
			if (error == noErr) {
				error = nil;
				NSData *imageData = [thumbNail readData:&error];
				
				if (imageData != nil && error == noErr) {
					cell.imageView.image = [UIImage imageWithData:imageData];
				}
			}
		} else {
			cell.imageView.image = [UIImage imageNamed:[fileInfo iconName]];
		}
		
        if (fileInfo.isFolder == YES) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		} else {
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%lld KB", fileInfo.size/1000];
		}
		
    } else {
		
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		}
		
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        if ([self accountIsLinked] == NO) {
            cell.textLabel.text = NSLocalizedString(@"Link to Dropbox", nil);
        } else {
            cell.textLabel.text = NSLocalizedString(@"Unlink from Dropbox", nil);
        }
    }
    
    return cell;
}



#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.filesArray count] > 0 && indexPath.section == 0) {
        
    } else {
        if ([self accountIsLinked] == NO) { // Link to Dropbox
			[[DBAccountManager sharedManager] linkFromController:self.navigationController];
		} else { // Unlink from Dropbox
			[[DBAccountManager sharedManager].linkedAccount unlink];
			[self.filesArray removeAllObjects];
			[self reload];
		}
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.filesArray count] > 0 && indexPath.section == 0) {
		return 64.0f;
	} else {
		return 44.0f;
	}
}


@end
