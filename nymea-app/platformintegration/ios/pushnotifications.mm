#import "UIKit/UIKit.h"
#import <UserNotifications/UserNotifications.h>

#include "pushnotifications.h"
#include "platformhelper.h"

#include <QDebug>

#import "Firebase/Firebase.h"

@interface FirebaseDelegate: NSObject<FIRMessagingDelegate>
@end

@implementation FirebaseDelegate
 - (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
     qDebug() << "Firebase token received:" << QString::fromNSString(fcmToken);
     dynamic_cast<PushNotifications*>(PushNotifications::instance())->setFirebaseRegistrationToken(QString::fromNSString(fcmToken));
 }
@end

// This is hidden, so we declare it here to hook into it
@interface QIOSApplicationDelegate: UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate>
@end

//add a category to QIOSApplicationDelegate
@interface QIOSApplicationDelegate (APNSApplicationDelegate)
// No need to declare the methods here, since we’re overriding existing ones
@end


@implementation QIOSApplicationDelegate (APNSApplicationDelegate)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;

    return YES;
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSLog(@"User Info : %@",notification.request.content.userInfo);
    qDebug() << "willPresentNotification called!";
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    NSLog(@"User Info : %@",response.notification.request.content.userInfo);
    qDebug() << "received notification response!";

    NSString *nymeaData = response.notification.request.content.userInfo[@"gcm.notification.nymeaData"];

    PlatformHelper::instance()->notificationActionReceived(QString::fromNSString(nymeaData));

    completionHandler();
}

- (void)tokenRefreshNotification:(NSNotification *)notification {
   NSLog(@"instanceId_notification=>%@",[notification object]);
    NSString *InstanceID = [NSString stringWithFormat:@"%@",[notification object]];
    qDebug() << "Notifation:" << QString::fromNSString(InstanceID);

}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo {
    qDebug() << "didReceiveRemoteNotification called";
}

@end

void PushNotifications::registerObjC()
{
    [FIRApp configure];
    [FIRMessaging messaging].delegate = [[FirebaseDelegate alloc] init];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}
