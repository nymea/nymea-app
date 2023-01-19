//#include <libnih.h>
//#include <libnih-dbus.h>

#include "platformhelperubports.h"


#include <QSettings>
#include <QUuid>
#include <QUrl>
#include <QUrlQuery>
#include <QDBusConnection>
#include <QDebug>
#include <QCoreApplication>


PlatformHelperUBPorts::PlatformHelperUBPorts(QObject *parent):
    PlatformHelper(parent),
    m_uriHandlerObject(this)
{
    setupUriHandler();
}

QString PlatformHelperUBPorts::platform() const
{
    return "ubports";
}

QString PlatformHelperUBPorts::deviceSerial() const
{
    QSettings s;
    if (!s.contains("deviceSerial")) {
        s.setValue("deviceSerial", QUuid::createUuid());
    }
    return s.value("deviceSerial").toString();
}

void PlatformHelperUBPorts::setupUriHandler()
{
    QString objectPath;

    if (!QDBusConnection::sessionBus().isConnected()) {
        qWarning() << "UCUriHandler: D-Bus session bus is not connected, ignoring.";
        return;
    }

    // Get the object path based on the "APP_ID" environment variable.
    QByteArray applicationId = qgetenv("APP_ID");
    if (applicationId.isEmpty()) {
        qWarning() << "UCUriHandler: Empty \"APP_ID\" environment variable, ignoring.";
        return;
    }
//    char* path = nih_dbus_path(NULL, "", applicationId.constData(), nullptr);
//    objectPath = QString::fromLocal8Bit(path);
//    nih_free(path);

    // Ensure handler is running on the main thread.
    QCoreApplication* instance = QCoreApplication::instance();
    if (instance) {
        moveToThread(instance->thread());
    } else {
        qWarning() << "UCUriHandler: Created before QCoreApplication, application may misbehave.";
    }

//    QDBusConnection::sessionBus().registerObject(
//        objectPath, &m_uriHandlerObject, QDBusConnection::ExportAllSlots);
}

UriHandlerObject::UriHandlerObject(PlatformHelper *platformHelper):
    m_platformHelper(platformHelper)
{
}

void UriHandlerObject::Open(const QStringList& uris, const QHash<QString, QVariant>& platformData)
{
    Q_UNUSED(platformData);
    foreach (const QString &uri, uris) {
        if (uri.startsWith("nymea://notification")) {
            m_platformHelper->notificationActionReceived(QUrlQuery(QUrl(uri)).queryItemValue("nymeaData"));
        }
    }
}
