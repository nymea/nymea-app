// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef PLATFORMHELPER_H
#define PLATFORMHELPER_H

#include <QObject>
#include <QColor>
#include <QHash>
#include <QUuid>
#include <QVariant>

class QQmlEngine;
class QJSEngine;

class PlatformHelper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString platform READ platform CONSTANT)
    Q_PROPERTY(QString deviceSerial READ deviceSerial CONSTANT)
    Q_PROPERTY(QString device READ device CONSTANT)
    Q_PROPERTY(QString deviceModel READ deviceModel CONSTANT)
    Q_PROPERTY(QString deviceManufacturer READ deviceManufacturer CONSTANT)
    Q_PROPERTY(QString machineHostname READ machineHostname CONSTANT)
    Q_PROPERTY(bool splashVisible READ splashVisible WRITE setSplashVisible NOTIFY splashVisibleChanged)
    Q_PROPERTY(bool canControlScreen READ canControlScreen CONSTANT)
    Q_PROPERTY(int screenTimeout READ screenTimeout WRITE setScreenTimeout NOTIFY screenTimeoutChanged)
    Q_PROPERTY(int screenBrightness READ screenBrightness WRITE setScreenBrightness NOTIFY screenBrightnessChanged)
    Q_PROPERTY(QColor topPanelColor READ topPanelColor WRITE setTopPanelColor NOTIFY topPanelColorChanged)
    Q_PROPERTY(QColor bottomPanelColor READ bottomPanelColor WRITE setBottomPanelColor NOTIFY bottomPanelColorChanged)
    Q_PROPERTY(bool darkModeEnabled READ darkModeEnabled NOTIFY darkModeEnabledChanged)
    Q_PROPERTY(QVariantList pendingNotificationActions READ pendingNotificationActions NOTIFY pendingNotificationActionsChanged)
    Q_PROPERTY(bool locationServicesEnabled READ locationServicesEnabled NOTIFY locationServicesEnabledChanged)
    Q_PROPERTY(int topPadding READ topPadding NOTIFY topPaddingChanged)
    Q_PROPERTY(int bottomPadding READ bottomPadding NOTIFY bottomPaddingChanged)
    Q_PROPERTY(int leftPadding READ leftPadding NOTIFY leftPaddingChanged)
    Q_PROPERTY(int rightPadding READ rightPadding NOTIFY rightPaddingChanged)

public:
    enum HapticsFeedback {
        HapticsFeedbackSelection,
        HapticsFeedbackImpact,
        HapticsFeedbackNotification
    };
    Q_ENUM(HapticsFeedback)

    static PlatformHelper* instance(bool create = true);
    virtual ~PlatformHelper() = default;

    virtual QString platform() const;
    virtual QString machineHostname() const;
    virtual QString device() const;
    virtual QString deviceSerial() const;
    virtual QString deviceModel() const;
    virtual QString deviceManufacturer() const;

    virtual bool canControlScreen() const;
    virtual int screenTimeout() const;
    virtual void setScreenTimeout(int screenTimeout);
    virtual int screenBrightness() const;
    virtual void setScreenBrightness(int percent);

    virtual QColor topPanelColor() const;
    virtual void setTopPanelColor(const QColor &color);
    virtual QColor bottomPanelColor() const;
    virtual void setBottomPanelColor(const QColor &color);

    virtual int topPadding() const;
    virtual int bottomPadding() const;
    virtual int leftPadding() const;
    virtual int rightPadding() const;

    virtual bool darkModeEnabled() const;

    QVariantList pendingNotificationActions() const;
    Q_INVOKABLE void notificationActionHandled(const QUuid &id);

    virtual bool splashVisible() const;
    virtual void setSplashVisible(bool splashVisible);
    Q_INVOKABLE virtual void hideSplashScreen();


    Q_INVOKABLE virtual void vibrate(HapticsFeedback feedbackType);

    Q_INVOKABLE virtual void toClipBoard(const QString &text);
    Q_INVOKABLE virtual QString fromClipBoard();

    Q_INVOKABLE virtual void shareFile(const QString &fileName);

    static QObject *platformHelperProvider(QQmlEngine *engine, QJSEngine *scriptEngine);

    void notificationActionReceived(const QString &nymeaData);

    virtual bool locationServicesEnabled() const;

signals:
    void screenTimeoutChanged();
    void screenBrightnessChanged();
    void topPanelColorChanged();
    void bottomPanelColorChanged();
    void darkModeEnabledChanged();
    void splashVisibleChanged();
    void pendingNotificationActionsChanged();
    void locationServicesEnabledChanged();
    void topPaddingChanged();
    void bottomPaddingChanged();
    void leftPaddingChanged();
    void rightPaddingChanged();

protected:
    explicit PlatformHelper(QObject *parent = nullptr);
    void setSafeAreaPadding(int top, int right, int bottom, int left);

private:
    static PlatformHelper *s_instance;

    QColor m_topPanelColor = QColor("black");
    QColor m_bottomPanelColor = QColor("black");

    bool m_splashVisible = true;

    QHash<QUuid, QVariant> m_pendingNotificationActions;

    int m_topPadding = 0;
    int m_bottomPadding = 0;
    int m_leftPadding = 0;
    int m_rightPadding = 0;
};

#endif // PLATFORMHELPER_H
