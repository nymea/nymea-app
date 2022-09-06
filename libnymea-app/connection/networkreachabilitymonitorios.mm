#include "networkreachabilitymonitor.h"

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <CoreFoundation/CoreFoundation.h>

#include <QLoggingCategory>
Q_DECLARE_LOGGING_CATEGORY(dcNymeaConnection)

void NetworkReachabilityMonitor::ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");

    NetworkReachabilityMonitor* thiz = (__bridge NetworkReachabilityMonitor *)info;
    // Post a notification to notify the client that the network reachability changed.
    NymeaConnection::BearerTypes old = thiz->m_availableBearerTypes;
    thiz->m_availableBearerTypes = flagsToBearerType(flags);
    qCDebug(dcNymeaConnection()) << "Network reachability changed. Old bearers:" << old << "New bearers:" << thiz->m_availableBearerTypes << "(Flags:" << flags << ")";
    if (thiz->m_availableBearerTypes != old) {
        emit thiz->availableBearerTypesChanged();
    }
    emit thiz->availableBearerTypesUpdated();
}

void NetworkReachabilityMonitor::setupIOS()
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;

    m_reachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zeroAddress);
    if (m_reachabilityRef == NULL) {
        qCCritical(dcNymeaConnection()) << "Error setting up reachability monitor";
        return;
    }

    SCNetworkReachabilityContext context = {0, (__bridge void *)(this), NULL, NULL, NULL};
    if (SCNetworkReachabilitySetCallback(m_reachabilityRef, ReachabilityCallback, &context)) {
        if (SCNetworkReachabilityScheduleWithRunLoop(m_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
        } else {
            qCCritical(dcNymeaConnection()) << "Error setting up reachability callback";
        }
    }

    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(m_reachabilityRef, &flags)) {
        m_availableBearerTypes = flagsToBearerType(flags);
    }
}

void NetworkReachabilityMonitor::teardownIOS()
{
    SCNetworkReachabilityUnscheduleFromRunLoop(m_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
}

NymeaConnection::BearerType NetworkReachabilityMonitor::flagsToBearerType(SCNetworkReachabilityFlags flags)
{
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        return NymeaConnection::BearerTypeNone;
    }

    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
        /*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
        return NymeaConnection::BearerTypeWiFi;
    }

    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
        (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */

        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            /*
             ... and no [user] intervention is needed...
             */
            return NymeaConnection::BearerTypeWiFi;
        }
    }

    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        /*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
        return NymeaConnection::BearerTypeMobileData;
    }

    return NymeaConnection::BearerTypeNone;
}
