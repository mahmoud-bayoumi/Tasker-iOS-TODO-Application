//
//  SceneDelegate.m
//  TODO
//
//  Created by Bayoumi on 07/04/2026.
//

#import "SceneDelegate.h"
#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    if (!center.delegate) {
        AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
        center.delegate = appDelegate;
    }
}

- (void)sceneDidDisconnect:(UIScene *)scene {
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)sceneWillResignActive:(UIScene *)scene {
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
}

@end
