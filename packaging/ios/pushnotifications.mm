#import "UIKit/UIKit.h"
#import <UserNotifications/UserNotifications.h>

// Include our C++ class
#include "pushnotifications.h"

#include <QDebug>

#import "Firebase/Firebase.h"


// This is hidden, so we declare it here to hook into it
@interface QIOSApplicationDelegate: UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate,FIRMessagingDelegate>
@end

//add a category to QIOSApplicationDelegate
@interface QIOSApplicationDelegate (APNSApplicationDelegate)
// No need to declare the methods here, since we’re overriding existing ones
@end


@implementation QIOSApplicationDelegate (APNSApplicationDelegate)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Use Firebase library to configure APIs
    [FIRApp configure];
    [FIRMessaging messaging].delegate = self;


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
    // We've switched to firebase... Not emitting the native APNS token
//    PushNotifications::instance()->setAPNSRegistrationToken(QString::fromNSString(tokenStr));
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

- (void)tokenRefreshNotification:(NSNotification *)notification {
   NSLog(@"instanceId_notification=>%@",[notification object]);
    NSString *InstanceID = [NSString stringWithFormat:@"%@",[notification object]];
    qDebug() << "Firebase token:" << QString::fromNSString(InstanceID);

}

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"FCM registration token: %@", fcmToken);
    // Notify about received token.
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
    [[NSNotificationCenter defaultCenter] postNotificationName:
     @"FCMToken" object:nil userInfo:dataDict];
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
    qDebug() << "Firebase token received:" << QString::fromNSString(fcmToken);
    PushNotifications::instance()->setAPNSRegistrationToken(QString::fromNSString(fcmToken));

}

@end
