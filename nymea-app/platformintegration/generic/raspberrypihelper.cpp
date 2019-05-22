#include "raspberrypihelper.h"

#include <QDebug>
#include <QApplication>
#include <QWindow>
#include <QSettings>

RaspberryPiHelper::RaspberryPiHelper(QObject *parent) : QObject(parent)
{
    m_sysFsFile.setFileName("/sys/class/backlight/rpi_backlight/bl_power");
    bool available = m_sysFsFile.open(QFile::ReadWrite | QFile::Text);

    if (!available) {
        return;
    }

    qDebug() << "Raspberry Pi detected. Enabling backlight control";

    screenOn();

    foreach (QWindow *w, qApp->topLevelWindows()) {
        w->installEventFilter(this);
    }

    QSettings settings;
    m_screenOffTimer.setInterval(settings.value("screenOffTimeout", 15000).toInt());
    m_screenOffTimer.setSingleShot(true);
    connect(&m_screenOffTimer, &QTimer::timeout, this, &RaspberryPiHelper::screenOff);
    if (m_screenOffTimer.interval() > 0) {
        m_screenOffTimer.start();
    }
}

bool RaspberryPiHelper::active() const
{
    return m_sysFsFile.isOpen();
}

int RaspberryPiHelper::screenTimeout() const
{
    return m_screenOffTimer.interval();
}

void RaspberryPiHelper::setScreenTimeout(int timeout)
{
    m_screenOffTimer.setInterval(timeout);
    QSettings settings;
    settings.setValue("screenOffTimeout", timeout);
    if (timeout > 0) {
        m_screenOffTimer.start();
    } else {
        m_screenOffTimer.stop();
    }
}

bool RaspberryPiHelper::eventFilter(QObject *watched, QEvent *event)
{
    if (m_screenOffTimer.interval() == 0) {
        return QObject::eventFilter(watched, event);
    }

    QList<QEvent::Type> watchedTypes = {
        QEvent::ActivationChange,
        QEvent::ApplicationStateChange,
        QEvent::KeyPress,
        QEvent::KeyRelease,
        QEvent::MouseButtonPress,
        QEvent::MouseButtonRelease,
        QEvent::MouseMove,
        QEvent::Show,
        QEvent::TouchBegin,
        QEvent::TouchEnd,
        QEvent::TouchUpdate,
    };
    if (!watchedTypes.contains(event->type())) {
        return QObject::eventFilter(watched, event);
    }

    if (!m_screenOffTimer.isActive()) {
        screenOn();
        m_screenOffTimer.start();
        return true;
    }
    m_screenOffTimer.start( );
    return QObject::eventFilter(watched, event);
}

void RaspberryPiHelper::screenOn()
{
    qDebug() << "Turning screen on";
    int ret = m_sysFsFile.write("0\n");
    m_sysFsFile.flush();
    if (ret < 0) {
        qWarning() << "Failed to power on screen";
    }
}

void RaspberryPiHelper::screenOff()
{
    qDebug() << "Turning screen off";
    int ret = m_sysFsFile.write("1\n");
    m_sysFsFile.flush();
    if (ret < 0) {
        qWarning() << "Failed to power off screen";
    }
}
