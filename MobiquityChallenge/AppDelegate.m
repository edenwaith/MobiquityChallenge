//
//  AppDelegate.m
//  MobiquityChallenge
//
//  Created by Chad Armstrong on 11/7/14.
//  Copyright (c) 2014 Chad Armstrong. All rights reserved.
//

#import "TargetConditionals.h"
#import <Dropbox/Dropbox.h>

#import "AppDelegate.h"
#import "ListFilesTableViewController.h"
#import "MobiquityConstants.h"

@interface AppDelegate ()

@property (nonatomic, strong) UINavigationController *rootController;
@property (nonatomic, strong) ListFilesTableViewController *listFilesController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:kAppKey secret:kAppSecret];
    [DBAccountManager setSharedManager:accountManager];
    
    DBAccount *account = [accountManager.linkedAccounts objectAtIndex:0];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
	self.listFilesController = [mainStoryboard instantiateViewControllerWithIdentifier:kListFilesTableViewID];
    
    if (account != nil) {
        DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
        [self.listFilesController setFilesystem:filesystem andRootPath:[DBPath root]];
    }
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.listFilesController];
    
    self.rootController = navigationController;
    
    self.window.rootViewController = navigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
	
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    
    if (account != nil) {
        
        DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
        [self.listFilesController setFilesystem:filesystem andRootPath:[DBPath root]];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
