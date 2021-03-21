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
#include <QLoggingCategory>

Q_DECLARE_LOGGING_CATEGORY(dcPlatformIntegration)

ScreenHelper::ScreenHelper(QObject *parent) : QObject(parent)
{
    // Try generic backlight
    QDir backlightDir("/sys/class/backlight");
    foreach (const QFileInfo &fi, backlightDir.entryInfoList({"*_backlight"}, QDir::Dirs)) {
        qCDebug(dcPlatformIntegration()) << "Checking backlight directory:" << fi.absoluteFilePath();
        m_powerFile.setFileName(fi.absoluteFilePath() + "/bl_power");
        m_brightnessFile.setFileName(fi.absoluteFilePath() + "/brightness");
        if (!m_powerFile.open(QFile::ReadWrite | QFile::Text)) {
            qCDebug(dcPlatformIntegration()) << "Cannot open" << m_powerFile.fileName() << "for writing";
            continue;
        }
        if (!m_brightnessFile.open(QFile::ReadWrite | QFile::Text)) {
            qCDebug(dcPlatformIntegration()) << "Cannot open" << m_brightnessFile.fileName() << "for writing";
            continue;
        }
        QFile maxBrightnessFile(fi.absoluteFilePath() + "/max_brightness");
        if (!maxBrightnessFile.open(QFile::ReadOnly)) {
            qCDebug(dcPlatformIntegration()) << "Cannot open" << m_brightnessFile.fileName() << "for reading";
            continue;
        }
        bool ok;
        m_maxBrightness = maxBrightnessFile.readLine().trimmed().toInt(&ok);
        if (!ok) {
            qCDebug(dcPlatformIntegration()) << "Error reading max brightness value from" << maxBrightnessFile.fileName();
            m_maxBrightness = -1;
            continue;
        }
        // All good. Let's use this and not check more files
        break;
    }

    if (!m_powerFile.isOpen() || !m_brightnessFile.isOpen()) {
        qCInfo(dcPlatformIntegration()) << "No backlight support on this platform";
        return;
    }
    qCInfo(dcPlatformIntegration()) << "Backlight control enabled on" << m_powerFile.fileName();

    bool ok;
    int currentBrightness = m_brightnessFile.readLine().trimmed().toInt(&ok);
    m_currentBrightness = currentBrightness * 100 / m_maxBrightness;
    qCInfo(dcPlatformIntegration()).nospace() << "Brigness: Absolute: " << currentBrightness << "/" << m_maxBrightness << " Percentage:" << m_currentBrightness;

    screenOn();

    foreach (QWindow *w, qApp->topLevelWindows()) {
        w->installEventFilter(this);
    }

    QSettings settings;

    m_currentBrightness = settings.value("screenBrightness", 80).toInt();


    m_screenDimTimer.setInterval(settings.value("screenOffTimeout", 30000).toInt());
    m_screenDimTimer.setSingleShot(true);
    connect(&m_screenDimTimer, &QTimer::timeout, this, &ScreenHelper::dimScreen);
    if (m_screenDimTimer.interval() > 0) {
        m_screenDimTimer.start();
    }

    m_screenOffTimer.setInterval(5000);
    m_screenOffTimer.setSingleShot(true);
    connect(&m_screenOffTimer, &QTimer::timeout, this, &ScreenHelper::screenOff);

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
    return m_screenDimTimer.interval();
}

void ScreenHelper::setScreenTimeout(int timeout)
{
    m_screenDimTimer.setInterval(timeout);
    QSettings settings;
    settings.setValue("screenOffTimeout", timeout);
    if (timeout > 0) {
        m_screenDimTimer.start();
    } else {
        m_screenDimTimer.stop();
    }
}

int ScreenHelper::screenBrightness() const
{
    return m_currentBrightness;
}

void ScreenHelper::setScreenBrightness(int percent)
{
    QSettings settings;
    settings.setValue("screenBrightness", percent);
    m_currentBrightness = percent;
    applyBrightness(m_currentBrightness);
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

    // No timer is active, means we've off already => turn on and start dim timer, eating the input event
    if (!m_screenDimTimer.isActive() && !m_screenOffTimer.isActive()) {
        screenOn();
        m_screenDimTimer.start();
        return true;
    }
    // Screen off timer is active, means we've dimmed down already => dim up again and stop offTimer
    if (m_screenOffTimer.isActive()) {
        m_screenOffTimer.stop();
        applyBrightness(m_currentBrightness);
    }
    // restart dim timer
    m_screenDimTimer.start();
    return QObject::eventFilter(watched, event);
}

void ScreenHelper::screenOn()
{
    qCInfo(dcPlatformIntegration()) << "Turning screen on";
    qint64 ret = m_powerFile.write("0\n");
    m_powerFile.flush();
    if (ret < 0) {
        qCWarning(dcPlatformIntegration()) << "Failed to power on screen";
    }
}

void ScreenHelper::screenOff()
{
    qCInfo(dcPlatformIntegration()) << "Turning screen off";
    qint64 ret = m_powerFile.write("1\n");
    m_powerFile.flush();
    if (ret < 0) {
        qCWarning(dcPlatformIntegration()) << "Failed to power off screen";
    }
    applyBrightness(m_currentBrightness);
}

void ScreenHelper::dimScreen()
{
    applyBrightness(qRound(m_currentBrightness * 0.5));
    m_screenOffTimer.start();
}

void ScreenHelper::applyBrightness(int percent)
{
    int absolue = percent * m_maxBrightness / 100;
    qCDebug(dcPlatformIntegration()) << "Setting screen brightness to" << absolue << "(" << percent << "%)";
    m_brightnessFile.write(QString("%1\n").arg(absolue).toUtf8());
    m_brightnessFile.flush();
}
