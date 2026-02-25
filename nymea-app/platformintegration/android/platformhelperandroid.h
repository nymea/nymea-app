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

#ifndef PLATFORMHELPERANDROID_H
#define PLATFORMHELPERANDROID_H

#include "platformhelper.h"

#include <QObject>
#include <QJniObject>
#include <QJniEnvironment>
#include <QtCore/private/qandroidextras_p.h>

class PlatformHelperAndroid : public PlatformHelper
{
    Q_OBJECT
public:
    enum Theme { Light, Dark };

    explicit PlatformHelperAndroid(QObject *parent = nullptr);

    Q_INVOKABLE void hideSplashScreen() override;

    QString machineHostname() const override;
    QString deviceSerial() const override;
    QString device() const override;
    QString deviceModel() const override;
    QString deviceManufacturer() const override;

    Q_INVOKABLE void vibrate(HapticsFeedback feedbackType) override;

    void setTopPanelColor(const QColor &color) override;
    void setTopPanelTheme(Theme theme);
    void setBottomPanelColor(const QColor &color) override;
    void setBottomPanelTheme(Theme theme);

    int topPadding() const override;
    int bottomPadding() const override;
    int leftPadding() const override;
    int rightPadding() const override;

    bool darkModeEnabled() const override;

    bool locationServicesEnabled() const override;

    void shareFile(const QString &fileName) override;

    static void darkModeEnabledChangedJNI();
    static void notificationActionReceivedJNI(JNIEnv *env, jobject /*thiz*/, jstring data);
    static void locationServicesEnabledChangedJNI();

private:
    void updateSafeAreaPadding();

};

#endif // PLATFORMHELPERANDROID_H
