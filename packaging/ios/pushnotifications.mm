#import "UIKit/UIKit.h"

// Include our C++ class
#include "pushnotifications.h"

// This is hidden, so we declare it here to hook into it
@interface QIOSApplicationDelegate
@end

//add a category to QIOSApplicationDelegate
@interface QIOSApplicationDelegate (APNSApplicationDelegate)
// No need to declare the methods here, since we’re overriding existing ones
@end

@implementation QIOSApplicationDelegate (APNSApplicationDelegate)

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Register to receive notifications from the system
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];

    [application registerForRemoteNotifications];
    NSLog(@"registered for remote notifications");
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Did Register for Remote Notifications with Device Token (%@)", deviceToken);
    const unsigned *tokenBytes = (const unsigned*)[deviceToken bytes];
    NSString *tokenStr = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];

    PushNotifications::instance()->setAPNSRegistrationToken(QString::fromNSString(tokenStr));
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Did Fail to Register for Remote Notifications");
    NSLog(@"%@, %@", error, error.localizedDescription);
}

@end
