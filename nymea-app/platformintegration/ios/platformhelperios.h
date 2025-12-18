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

#ifndef PLATFORMHELPERIOS_H
#define PLATFORMHELPERIOS_H

#include <QObject>

#include "platformhelper.h"

class PlatformHelperIOS : public PlatformHelper
{
    Q_OBJECT
public:
    explicit PlatformHelperIOS(QObject *parent = nullptr);

    Q_INVOKABLE void hideSplashScreen() override;

    virtual QString machineHostname() const override;
    virtual QString device() const override;
    virtual QString deviceSerial() const override;
    virtual QString deviceModel() const override;
    virtual QString deviceManufacturer() const override;

    Q_INVOKABLE virtual void vibrate(HapticsFeedback feedbackType) override;

    void setTopPanelColor(const QColor &color) override;
    void setBottomPanelColor(const QColor &color) override;

    bool darkModeEnabled() const override;

    void shareFile(const QString &fileName) override;

private:
    // defined in platformhelperios.mm
    QString deviceName() const;
    QString readKeyChainEntry(const QString &service, const QString &key);
    void writeKeyChainEntry(const QString &service, const QString &key, const QString &value);

    void setTopPanelColorInternal(const QColor &color);
    void setBottomPanelColorInternal(const QColor &color);

    void generateSelectionFeedback();
    void generateImpactFeedback();
    void generateNotificationFeedback();

    void applyPanelColors();
    void updateSafeAreaPadding();
};

#endif // PLATFORMHELPERIOS_H
