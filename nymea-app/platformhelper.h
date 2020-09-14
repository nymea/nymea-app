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

#ifndef PLATFORMHELPER_H
#define PLATFORMHELPER_H

#include <QObject>
#include <QColor>

class PlatformHelper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool hasPermissions READ hasPermissions NOTIFY permissionsRequestFinished)
    Q_PROPERTY(QString deviceSerial READ deviceSerial CONSTANT)
    Q_PROPERTY(QString device READ device CONSTANT)
    Q_PROPERTY(QString deviceModel READ deviceModel CONSTANT)
    Q_PROPERTY(QString deviceManufacturer READ deviceManufacturer CONSTANT)
    Q_PROPERTY(QString machineHostname READ machineHostname CONSTANT)
    Q_PROPERTY(bool canControlScreen READ canControlScreen CONSTANT)
    Q_PROPERTY(int screenTimeout READ screenTimeout WRITE setScreenTimeout NOTIFY screenTimeoutChanged)
    Q_PROPERTY(int screenBrightness READ screenBrightness WRITE setScreenBrightness NOTIFY screenBrightnessChanged)
    Q_PROPERTY(QColor topPanelColor READ topPanelColor WRITE setTopPanelColor NOTIFY topPanelColorChanged)
    Q_PROPERTY(QColor bottomPanelColor READ bottomPanelColor WRITE setBottomPanelColor NOTIFY bottomPanelColorChanged)

public:
    enum HapticsFeedback {
        HapticsFeedbackSelection,
        HapticsFeedbackImpact,
        HapticsFeedbackNotification
    };
    Q_ENUM(HapticsFeedback)

    explicit PlatformHelper(QObject *parent = nullptr);
    virtual ~PlatformHelper() = default;

    Q_INVOKABLE virtual void requestPermissions() = 0;

    Q_INVOKABLE virtual void hideSplashScreen() = 0;

    virtual bool hasPermissions() const = 0;
    virtual QString machineHostname() const = 0;
    virtual QString device() const = 0;
    virtual QString deviceSerial() const = 0;
    virtual QString deviceModel() const = 0;
    virtual QString deviceManufacturer() const = 0;

    virtual bool canControlScreen() const;
    virtual int screenTimeout() const;
    virtual void setScreenTimeout(int screenTimeout);
    virtual int screenBrightness() const;
    virtual void setScreenBrightness(int percent);

    virtual QColor topPanelColor() const;
    virtual void setTopPanelColor(const QColor &color);
    virtual QColor bottomPanelColor() const;
    virtual void setBottomPanelColor(const QColor &color);


    Q_INVOKABLE virtual void vibrate(HapticsFeedback feedbackType) = 0;

    Q_INVOKABLE virtual void toClipBoard(const QString &text);
    Q_INVOKABLE virtual QString fromClipBoard();

    Q_INVOKABLE virtual void syncThings();

signals:
    void permissionsRequestFinished();
    void screenTimeoutChanged();
    void screenBrightnessChanged();
    void topPanelColorChanged();
    void bottomPanelColorChanged();

private:
    QColor m_topPanelColor = QColor("black");
    QColor m_bottomPanelColor = QColor("black");
};

#endif // PLATFORMHELPER_H
