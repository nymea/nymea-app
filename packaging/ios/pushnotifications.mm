#import "UIKit/UIKit.h"
#import <UserNotifications/UserNotifications.h>

// Include our C++ class
#include "pushnotifications.h"

#include <QDebug>

// This is hidden, so we declare it here to hook into it
@interface QIOSApplicationDelegate: UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate>
@end

//add a category to QIOSApplicationDelegate
@interface QIOSApplicationDelegate (APNSApplicationDelegate)
// No need to declare the methods here, since we’re overriding existing ones
@end


@implementation QIOSApplicationDelegate (APNSApplicationDelegate)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Register to receive notifications from the system
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
        if(!error){
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
    }];

    NSLog(@"registering for remote notifications");
    qDebug() << "Registering for remote notifications";
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Did Register for Remote Notifications with Device Token (%@)", deviceToken);

    const unsigned *tokenBytes = (const unsigned*)[deviceToken bytes];
    NSString *tokenStr = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];

    qDebug() << "Registering for remote notifications";
    qDebug() << "Token description:" << QString::fromNSString(deviceToken.description);
    qDebug() << "Parsed token:" << QString::fromNSString(tokenStr);
    PushNotifications::instance()->setAPNSRegistrationToken(QString::fromNSString(tokenStr));
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Did Fail to Register for Remote Notifications");
    NSLog(@"%@, %@", error, error.localizedDescription);
    qWarning() << "Failed to register for notifications:" << QString::fromNSString(error.localizedDescription);
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSLog(@"User Info : %@",notification.request.content.userInfo);
    qDebug() << "willPresentNotification called!";
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    NSLog(@"User Info : %@",response.notification.request.content.userInfo);
    qDebug() << "received notification response!";
    completionHandler();
}

@end
