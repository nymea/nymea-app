/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "screenhelper.h"

#include <QDebug>
#include <QApplication>
#include <QWindow>
#include <QSettings>
#include <QFileInfo>
#include <QDir>

ScreenHelper::ScreenHelper(QObject *parent) : QObject(parent)
{
    // Try generic backlight
    QDir backlightDir("/sys/class/backlight");
    foreach (const QFileInfo &fi, backlightDir.entryInfoList({"*_backlight"}, QDir::Dirs)) {
        qDebug() << "Checking backlight directory:" << fi.absoluteFilePath();
        m_powerFile.setFileName(fi.absoluteFilePath() + "/bl_power");
        m_brightnessFile.setFileName(fi.absoluteFilePath() + "/brightness");
        if (!m_powerFile.open(QFile::ReadWrite | QFile::Text)) {
            qWarning() << "Cannot open" << m_powerFile.fileName() << "for writing";
            continue;
        }
        if (!m_brightnessFile.open(QFile::ReadWrite | QFile::Text)) {
            qWarning() << "Cannot open" << m_brightnessFile.fileName() << "for writing";
            continue;
        }
        QFile maxBrightnessFile(fi.absoluteFilePath() + "/max_brightness");
        if (!maxBrightnessFile.open(QFile::ReadOnly)) {
            qWarning() << "Cannot open" << m_brightnessFile.fileName() << "for reading";
            continue;
        }
        bool ok;
        m_maxBrightness = maxBrightnessFile.readAll().toInt(&ok);
        if (!ok) {
            qWarning() << "Error reading max brightness value from" << maxBrightnessFile.fileName();
            m_maxBrightness = -1;
            continue;
        }
        // All good. Let's use this and not check more files
        break;
    }

    if (!m_powerFile.isOpen() || !m_brightnessFile.isOpen()) {
        qWarning() << "No backlight support on this platform";
        return;
    }
    qDebug() << "Backlight control enabled on" << m_powerFile.fileName();

    QByteArray currentBrightness = m_brightnessFile.readLine();
    m_currentBrightness = currentBrightness.trimmed().toInt() * 100 / m_maxBrightness;
    qDebug() << "Current brightness is: Absolute:" << currentBrightness << "Percentage:" << m_currentBrightness;

    screenOn();

    foreach (QWindow *w, qApp->topLevelWindows()) {
        w->installEventFilter(this);
    }

    QSettings settings;
    m_screenOffTimer.setInterval(settings.value("screenOffTimeout", 15000).toInt());
    m_screenOffTimer.setSingleShot(true);
    connect(&m_screenOffTimer, &QTimer::timeout, this, &ScreenHelper::screenOff);
    if (m_screenOffTimer.interval() > 0) {
        m_screenOffTimer.start();
    }

    // Hide the mouse cursor right away, it'll be restored on mouse move events
    QApplication::setOverrideCursor(Qt::BlankCursor);
    m_cursorHidden = true;
}

bool ScreenHelper::active() const
{
    return m_powerFile.isOpen();
}

int ScreenHelper::screenTimeout() const
{
    return m_screenOffTimer.interval();
}

void ScreenHelper::setScreenTimeout(int timeout)
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

int ScreenHelper::screenBrightness() const
{
    return m_currentBrightness;
}

void ScreenHelper::setScreenBrightness(int percent)
{
    m_currentBrightness = percent;
    m_brightnessFile.write(QString("%1\n").arg(percent * 255 / 100).toUtf8());
    m_brightnessFile.flush();
}

bool ScreenHelper::eventFilter(QObject *watched, QEvent *event)
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

    // Hide the mouse cursor if touchscreen events are coming in
    QList<QEvent::Type> touchTypes = {
        QEvent::TouchBegin,
        QEvent::TouchUpdate,
        QEvent::TouchEnd
    };
    if (touchTypes.contains(event->type()) && !m_cursorHidden) {
        QApplication::setOverrideCursor(Qt::BlankCursor);
        m_cursorHidden = true;
    }

    // Restore the mouse cursor if hidden and mouse events come in
    QList<QEvent::Type> mouseTypes = {
        QEvent::MouseMove,
        QEvent::MouseButtonPress,
        QEvent::GrabMouse
    };
    if (mouseTypes.contains(event->type()) && m_cursorHidden) {
        QApplication::restoreOverrideCursor();
        m_cursorHidden = false;
    }


    if (!m_screenOffTimer.isActive()) {
        screenOn();
        m_screenOffTimer.start();
        return true;
    }
    m_screenOffTimer.start( );
    return QObject::eventFilter(watched, event);
}

void ScreenHelper::screenOn()
{
    qDebug() << "Turning screen on";
    int ret = m_powerFile.write("0\n");
    m_powerFile.flush();
    if (ret < 0) {
        qWarning() << "Failed to power on screen";
    }
}

void ScreenHelper::screenOff()
{
    qDebug() << "Turning screen off";
    int ret = m_powerFile.write("1\n");
    m_powerFile.flush();
    if (ret < 0) {
        qWarning() << "Failed to power off screen";
    }
}
