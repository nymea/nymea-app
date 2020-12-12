#include "platformhelperubports.h"

PlatformHelperUBPorts::PlatformHelperUBPorts(QObject *parent) : PlatformHelper(parent)
{

}

QString PlatformHelperUBPorts::platform() const
{
    return "ubports";
}
