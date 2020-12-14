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
    return s.value("deviceSerial", QUuid::createUuid()).toString();
}
