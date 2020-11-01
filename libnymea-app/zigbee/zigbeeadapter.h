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

#ifndef ZIGBEEADAPTER_H
#define ZIGBEEADAPTER_H

#include <QObject>

class ZigbeeAdapter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString description READ description WRITE setDescription NOTIFY descriptionChanged)
    Q_PROPERTY(QString systemLocation READ systemLocation WRITE setSystemLocation NOTIFY systemLocationChanged)
    Q_PROPERTY(bool hardwareRecognized READ hardwareRecognized WRITE setHardwareRecognized NOTIFY hardwareRecognizedChanged)
    Q_PROPERTY(ZigbeeAdapter::ZigbeeBackendType backendType READ backendType WRITE setBackendType NOTIFY backendTypeChanged)
    Q_PROPERTY(qint32 baudRate READ baudRate WRITE setBaudRate NOTIFY baudRateChanged)

public:
    enum ZigbeeBackendType {
        ZigbeeBackendTypeDeconz,
        ZigbeeBackendTypeNxp
    };
    Q_ENUM(ZigbeeBackendType)

    explicit ZigbeeAdapter(QObject *parent = nullptr);

    QString name() const;
    void setName(const QString &name);

    QString description() const;
    void setDescription(const QString &description);

    QString systemLocation() const;
    void setSystemLocation(const QString &systemLocation);

    bool hardwareRecognized() const;
    void setHardwareRecognized(bool hardwareRecognized);

    ZigbeeAdapter::ZigbeeBackendType backendType() const;
    void setBackendType(ZigbeeAdapter::ZigbeeBackendType backendType);

    qint32 baudRate() const;
    void setBaudRate(qint32 baudRate);

    bool operator==(const ZigbeeAdapter &other) const;

    static ZigbeeAdapter::ZigbeeBackendType stringToZigbeeBackendType(const QString &backendTypeString);

private:
    QString m_name;
    QString m_description;
    QString m_systemLocation;
    bool m_hardwareRecognized = false;
    ZigbeeAdapter::ZigbeeBackendType m_backendType = ZigbeeAdapter::ZigbeeBackendTypeDeconz;
    qint32 m_baudRate = 38400;

signals:
    void nameChanged();
    void descriptionChanged();
    void systemLocationChanged();
    void hardwareRecognizedChanged();
    void backendTypeChanged();
    void baudRateChanged();
};

#endif // ZIGBEEADAPTER_H
