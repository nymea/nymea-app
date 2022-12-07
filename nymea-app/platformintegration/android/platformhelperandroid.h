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

#ifndef PLATFORMHELPERANDROID_H
#define PLATFORMHELPERANDROID_H

#include "platformhelper.h"

#include <QObject>
#include <QtAndroid>
#include <QAndroidServiceConnection>

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

    bool darkModeEnabled() const override;

    bool locationServicesEnabled() const override;

    void shareFile(const QString &fileName) override;

    static void darkModeEnabledChangedJNI();
    static void notificationActionReceivedJNI(JNIEnv *env, jobject /*thiz*/, jstring data);
    static void locationServicesEnabledChangedJNI();

private:
    static void permissionRequestFinished(const QtAndroid::PermissionResultMap &);
};

#endif // PLATFORMHELPERANDROID_H
