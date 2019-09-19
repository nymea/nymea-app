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

QColor PlatformHelper::topPanelColor() const
{
    return m_topPanelColor;
}

void PlatformHelper::setTopPanelColor(const QColor &color)
{
    if (m_topPanelColor != color) {
        m_topPanelColor = color;
        emit topPanelColorChanged();
    }
}

QColor PlatformHelper::bottomPanelColor() const
{
    return m_bottomPanelColor;
}

void PlatformHelper::setBottomPanelColor(const QColor &color)
{
    if (m_bottomPanelColor != color) {
        m_bottomPanelColor = color;
        emit bottomPanelColorChanged();
    }
}
