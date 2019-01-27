
#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <UIKit/UIKit.h>

#include <QtDebug>
#include "platformintegration/ios/platformhelperios.h"


QString PlatformHelperIOS::readKeyChainEntry(const QString &service, const QString &key)
{
    NSDictionary *const query = @{
        (__bridge id) kSecClass: (__bridge id) kSecClassGenericPassword,
            (__bridge id) kSecAttrService: (__bridge NSString *) service.toCFString(),
            (__bridge id) kSecAttrAccount: (__bridge NSString *) key.toCFString(),
            (__bridge id) kSecReturnData: @YES,
    };

    CFTypeRef dataRef = nil;
    const OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) query, &dataRef);

    QByteArray data;
    if (status == errSecSuccess) {
        if (dataRef)
            data = QByteArray::fromCFData((CFDataRef) dataRef);

    } else {
        qWarning() << "Error accessing keychain value" << status;
    }

    if (dataRef)
        [dataRef release];

    return data;
}

void PlatformHelperIOS::writeKeyChainEntry(const QString &service, const QString &key, const QString &value)
{
    NSDictionary *const query = @{
            (__bridge id) kSecClass: (__bridge id) kSecClassGenericPassword,
            (__bridge id) kSecAttrService: (__bridge NSString *) service.toCFString(),
            (__bridge id) kSecAttrAccount: (__bridge NSString *) key.toCFString(),
    };

    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) query, nil);

    if (status == errSecSuccess) {
        NSDictionary *const update = @{
                (__bridge id) kSecValueData: (__bridge NSData *) value.toUtf8().toCFData(),
        };

        status = SecItemUpdate((__bridge CFDictionaryRef) query, (__bridge CFDictionaryRef) update);
    } else {
        NSDictionary *const insert = @{
                (__bridge id) kSecClass: (__bridge id) kSecClassGenericPassword,
                (__bridge id) kSecAttrService: (__bridge NSString *) service.toCFString(),
                (__bridge id) kSecAttrAccount: (__bridge NSString *) key.toCFString(),
                (__bridge id) kSecValueData: (__bridge NSData *) value.toUtf8().toCFData(),
        };

        status = SecItemAdd((__bridge CFDictionaryRef) insert, nil);
    }

    if (status == errSecSuccess) {
        qDebug() << "Successfully stored value in keychain";
    } else {
        qWarning() << "Error storing value in keycahin" << status;
    }
}


void PlatformHelperIOS::generateSelectionFeedback()
{
    UISelectionFeedbackGenerator *generator = [[UISelectionFeedbackGenerator alloc] init];
    [generator prepare];
    [generator selectionChanged];
    generator = nil;
}

void PlatformHelperIOS::generateImpactFeedback()
{
    // UIImpactFeedbackStyleLight
    // UIImpactFeedbackStyleMedium
    // UIImpactFeedbackStyleHeavy
    UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    [generator prepare];
    [generator impactOccurred];
    generator = nil;
}

void PlatformHelperIOS::generateNotificationFeedback()
{
//    UINotificationFeedbackTypeSuccess
//    UINotificationFeedbackTypeWarning
//    UINotificationFeedbackTypeError

    UINotificationFeedbackGenerator *generator = [[UINotificationFeedbackGenerator alloc] init];
    [generator prepare];
    [generator notificationOccurred:UINotificationFeedbackTypeSuccess];
    generator = nil;
}
