//
//  AppDelegate.m
//  TODO
//
//  Created by Bayoumi on 07/04/2026.
//
#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    
    NSLog(@"AppDelegate: Notification delegate set");
    
    return YES;
}



- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    NSLog(@"Notification received in foreground: %@",
          notification.request.content.body);
    
    if (@available(iOS 14.0, *)) {
        completionHandler(UNNotificationPresentationOptionBanner |
                          UNNotificationPresentationOptionSound |
                          UNNotificationPresentationOptionBadge);
    } else {
        completionHandler(UNNotificationPresentationOptionAlert |
                          UNNotificationPresentationOptionSound |
                          UNNotificationPresentationOptionBadge);
    }
}


- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    
    NSLog(@"User tapped notification: %@",
          response.notification.request.content.body);
    
    completionHandler();
}


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
}

@end
