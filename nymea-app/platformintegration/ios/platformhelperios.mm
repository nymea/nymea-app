
#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <UIKit/UIKit.h>

#include <QFileInfo>
#include <QUrl>

#include <QtDebug>
#include <QtGlobal>
#include "platformintegration/ios/platformhelperios.h"

@interface NymeaDocumentPickerDelegate : NSObject <UIDocumentPickerDelegate>
@property(nonatomic, assign) PlatformHelperIOS *helper;
@end

static NymeaDocumentPickerDelegate *s_documentPickerDelegate = nil;

static UIWindow *activeWindow()
{
    UIApplication *application = [UIApplication sharedApplication];
    UIWindow *window = application.keyWindow;
    if (window) {
        return window;
    }

    for (UIWindow *candidate in application.windows) {
        if (candidate.isKeyWindow) {
            return candidate;
        }
    }

    return application.windows.firstObject;
}

static UIViewController *activeViewController()
{
    UIWindow *window = activeWindow();
    UIViewController *controller = window.rootViewController;
    while (controller.presentedViewController) {
        controller = controller.presentedViewController;
    }
    return controller;
}

static CGRect statusBarFrameForWindow(UIWindow *window)
{
    if (!window) {
        return CGRectZero;
    }

    if (@available(iOS 13.0, *)) {
        UIStatusBarManager *statusBarManager = window.windowScene.statusBarManager;
        if (statusBarManager) {
            CGRect frame = statusBarManager.statusBarFrame;
            if (!CGRectIsEmpty(frame)) {
                return frame;
            }
        }
        CGFloat height = window.safeAreaInsets.top;
        return CGRectMake(0, 0, window.bounds.size.width, height);
    }

    return [UIApplication sharedApplication].statusBarFrame;
}

static bool removeSandboxFileAtPath(NSString *path)
{
    if (!path) {
        return false;
    }

    NSString *homePath = NSHomeDirectory();
    if (!path || !homePath || ![path hasPrefix:[homePath stringByAppendingString:@"/"]]) {
        return false;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDirectory] || isDirectory) {
        return false;
    }

    return [fileManager removeItemAtPath:path error:nil];
}

static bool removeSandboxFileAtPath(const QString &localPath)
{
    if (localPath.isEmpty()) {
        return false;
    }

    return removeSandboxFileAtPath(localPath.toNSString());
}

static QString localPathFromFileArgument(const QString &fileName)
{
    const QUrl url(fileName);
    return url.isLocalFile() ? url.toLocalFile() : fileName;
}

static void emitPickedFileUrl(PlatformHelperIOS *helper, NSURL *url)
{
    if (!helper) {
        return;
    }

    if (!url || !url.isFileURL) {
        emit helper->filePickError(QObject::tr("The selected file could not be accessed."));
        return;
    }

    const QString filePath = QString::fromNSString(url.path);
    if (filePath.isEmpty()) {
        emit helper->filePickError(QObject::tr("The selected file could not be accessed."));
        return;
    }

    emit helper->filePicked(QUrl::fromLocalFile(filePath), QFileInfo(filePath).fileName());
}

@implementation NymeaDocumentPickerDelegate

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    Q_UNUSED(controller)

    if (self.helper) {
        emit self.helper->filePickCanceled();
    }

    s_documentPickerDelegate = nil;
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls
{
    Q_UNUSED(controller)

    PlatformHelperIOS *helper = self.helper;
    s_documentPickerDelegate = nil;

    emitPickedFileUrl(helper, urls.firstObject);
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    Q_UNUSED(controller)

    PlatformHelperIOS *helper = self.helper;
    s_documentPickerDelegate = nil;

    emitPickedFileUrl(helper, url);
}

@end

QString PlatformHelperIOS::deviceName() const
{
    NSString *const name = UIDevice.currentDevice.name;
    if (!name) {
        return QString();
    }
    return QString::fromNSString(name).trimmed();
}

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
        CFRelease(dataRef); // SecItemCopyMatching creates a retained object; release with CFRelease.

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

void PlatformHelperIOS::setTopPanelColorInternal(const QColor &color)
{
    UIWindow *window = activeWindow();
    if (!window) {
        return;
    }

    static const NSInteger statusBarViewTag = 0x6E796D; // "nym" to avoid clashes
    UIColor *uiColor = [UIColor colorWithRed:color.redF() green:color.greenF() blue:color.blueF() alpha:color.alphaF()];
    CGRect frame = statusBarFrameForWindow(window);
    UIView *statusBar = [window viewWithTag:statusBarViewTag];
    if (statusBar) {
        statusBar.frame = frame;
    } else {
        statusBar = [[UIView alloc] initWithFrame:frame];
        statusBar.tag = statusBarViewTag;
        statusBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [window addSubview:statusBar];
    }
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = uiColor;
    }
    [window bringSubviewToFront:statusBar];

    if (((color.red() * 299 + color.green() * 587 + color.blue() * 114) / 1000) > 123) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent animated:YES];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }
}

void PlatformHelperIOS::setBottomPanelColorInternal(const QColor &color)
{
    //Bottom
    UIColor *uiColor = [UIColor colorWithRed:color.redF() green:color.greenF() blue:color.blueF() alpha:color.alphaF()];
    UIWindow *window = activeWindow();
    if (!window) {
        return;
    }

    window.backgroundColor = uiColor;
    if (window.rootViewController && window.rootViewController.view) {
        window.rootViewController.view.backgroundColor = uiColor;
    }
}

bool PlatformHelperIOS::darkModeEnabled() const
{
    if (@available(iOS 12.0, *)) {
        return UIScreen.mainScreen.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
    }
    return false;
}

static void shareFileInternal(const QString &fileName, bool removeAfterSharing)
{
    const QString localPath = localPathFromFileArgument(fileName);
    if (localPath.isEmpty()) {
        return;
    }

    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:localPath.toNSString()]] applicationActivities:nil];
    UIViewController *qtController = activeViewController();
    if (!qtController) {
        if (removeAfterSharing) {
            removeSandboxFileAtPath(localPath);
        }
        return;
    }

    if (removeAfterSharing) {
        NSString *pathToRemove = [localPath.toNSString() copy];
        activityController.completionWithItemsHandler = ^(UIActivityType activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            Q_UNUSED(activityType)
            Q_UNUSED(completed)
            Q_UNUSED(returnedItems)
            Q_UNUSED(activityError)
            removeSandboxFileAtPath(pathToRemove);
        };
    }

    UIPopoverPresentationController *popover = activityController.popoverPresentationController;
    if (popover) {
        UIView *sourceView = qtController.view ?: activeWindow();
        popover.sourceView = sourceView;
        popover.sourceRect = sourceView.bounds;
    }

    [qtController presentViewController:activityController animated:YES completion:nil];
}

void PlatformHelperIOS::shareFile(const QString &fileName)
{
    shareFileInternal(fileName, false);
}

void PlatformHelperIOS::shareTemporaryFile(const QString &fileName)
{
    shareFileInternal(fileName, true);
}

void PlatformHelperIOS::removeFile(const QUrl &fileUrl)
{
    const QString localPath = fileUrl.isLocalFile() ? fileUrl.toLocalFile() : fileUrl.toString();
    removeSandboxFileAtPath(localPath);
}

void PlatformHelperIOS::pickFile()
{
    UIViewController *qtController = activeViewController();
    if (!qtController) {
        emit filePickError(tr("The file picker is not available right now."));
        return;
    }

    if (s_documentPickerDelegate) {
        emit filePickError(tr("Another file picker is already open."));
        return;
    }

    UIDocumentPickerViewController *picker = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"] inMode:UIDocumentPickerModeImport];
#pragma clang diagnostic pop
    picker.allowsMultipleSelection = NO;

    NymeaDocumentPickerDelegate *delegate = [[NymeaDocumentPickerDelegate alloc] init];
    delegate.helper = this;
    picker.delegate = delegate;
    s_documentPickerDelegate = delegate;

    UIPopoverPresentationController *popover = picker.popoverPresentationController;
    if (popover) {
        UIView *sourceView = qtController.view ?: activeWindow();
        popover.sourceView = sourceView;
        popover.sourceRect = sourceView.bounds;
    }

    [qtController presentViewController:picker animated:YES completion:nil];
}

void PlatformHelperIOS::updateSafeAreaPadding()
{
    UIWindow *window = activeWindow();
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (window) {
        if (@available(iOS 11.0, *)) {
            insets = window.safeAreaInsets;
        } else {
            CGRect statusFrame = statusBarFrameForWindow(window);
            insets.top = statusFrame.size.height;
        }
    }
    setSafeAreaPadding(qRound(insets.top), qRound(insets.right), qRound(insets.bottom), qRound(insets.left));
}
