#include "platformhelper.h"

PlatformHelper::PlatformHelper(QObject *parent) : QObject(parent)
{

}

bool PlatformHelper::canControlScreen() const
{
    return false;
}

int PlatformHelper::screenTimeout() const
{
    return 0;
}

void PlatformHelper::setScreenTimeout(int screenTimeout)
{
    Q_UNUSED(screenTimeout)
}

int PlatformHelper::screenBrightness() const
{
    return 0;
}

void PlatformHelper::setScreenBrightness(int percent)
{
    Q_UNUSED(percent)
}
