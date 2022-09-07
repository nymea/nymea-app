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
    NetworkReachabilityMonitor* thiz = (__bridge NetworkReachabilityMonitor *)info;

    NymeaConnection::BearerTypes newTypes = thiz->m_availableBearerTypes;

    if (target == thiz->m_internetReachabilityRef) {
        // If the internet reachability changes, enable the mobile data bearer if we're reaching the internet through mobile data
        newTypes.setFlag(NymeaConnection::BearerTypeMobileData, (flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsWWAN));
        qCDebug(dcNymeaConnection()) << "Internet reachability changed";
    } else if (target == thiz->m_lanReachabilityRef) {
        // If the lan reachability changes, we'll enable the wifi bearer, regardless of how
        newTypes.setFlag(NymeaConnection::BearerTypeWiFi, flags & kSCNetworkReachabilityFlagsReachable);
        qCDebug(dcNymeaConnection()) << "LAN reachability changed";
    }

    qCDebug(dcNymeaConnection()) << "Old bearers:" << thiz->m_availableBearerTypes << QString("new network reachability flags: %1%2 %3%4%5%6%7%8%9")
          .arg((flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-')
          .arg((flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-')

          .arg((flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-')
          .arg((flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-')
          .arg((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-')
          .arg((flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-')
          .arg((flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-')
          .arg((flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-')
          .arg((flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-')
                                 << "new bearers:" << newTypes;

    if (thiz->m_availableBearerTypes != newTypes) {
        thiz->m_availableBearerTypes = newTypes;
        emit thiz->availableBearerTypesChanged();
    }
    emit thiz->availableBearerTypesUpdated();

}

void NetworkReachabilityMonitor::setupIOS()
{
    SCNetworkReachabilityContext context = {0, (__bridge void *)(this), NULL, NULL, NULL};

    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;

    m_internetReachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zeroAddress);

    if (m_internetReachabilityRef) {
        if (SCNetworkReachabilitySetCallback(m_internetReachabilityRef, ReachabilityCallback, &context)) {
            if (SCNetworkReachabilityScheduleWithRunLoop(m_internetReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
            } else {
                qCCritical(dcNymeaConnection()) << "Error setting up internet reachability callback (runloop)";
            }
        }

        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(m_internetReachabilityRef, &flags)) {
            m_availableBearerTypes.setFlag(NymeaConnection::BearerTypeMobileData, (flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsWWAN));
        }
    } else {
        qCCritical(dcNymeaConnection()) << "Error setting up internet reachability monitor (register)";
    }


    struct sockaddr_in linkLocalAddress;
    bzero(&linkLocalAddress, sizeof(linkLocalAddress));
    linkLocalAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
    linkLocalAddress.sin_len = sizeof(linkLocalAddress);
    linkLocalAddress.sin_family = AF_INET;

    m_lanReachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&linkLocalAddress);

    if (m_lanReachabilityRef) {
        if (SCNetworkReachabilitySetCallback(m_lanReachabilityRef, ReachabilityCallback, &context)) {
            if (SCNetworkReachabilityScheduleWithRunLoop(m_lanReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
            } else {
                qCCritical(dcNymeaConnection()) << "Error setting up LAN reachability callback (runloop)";
            }
        }

        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(m_lanReachabilityRef, &flags)) {
            m_availableBearerTypes.setFlag(NymeaConnection::BearerTypeWiFi, flags & kSCNetworkReachabilityFlagsReachable);
        }
    } else {
        qCCritical(dcNymeaConnection()) << "Error setting up LAN reachability monitor (register)";
    }

}

void NetworkReachabilityMonitor::teardownIOS()
{
    if (m_internetReachabilityRef) {
        SCNetworkReachabilityUnscheduleFromRunLoop(m_internetReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        CFRelease(m_internetReachabilityRef);
        m_internetReachabilityRef = nullptr;
    }
    if (m_lanReachabilityRef) {
        SCNetworkReachabilityUnscheduleFromRunLoop(m_lanReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        CFRelease(m_lanReachabilityRef);
        m_lanReachabilityRef = nullptr;
    }
}
