#include "platformhelperubports.h"

#include <QSettings>
#include <QUuid>

PlatformHelperUBPorts::PlatformHelperUBPorts(QObject *parent) : PlatformHelper(parent)
{

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
