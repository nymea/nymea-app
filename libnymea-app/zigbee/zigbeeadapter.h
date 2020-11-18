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

#include <QDebug>
#include <QObject>

class ZigbeeAdapter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString description READ description WRITE setDescription NOTIFY descriptionChanged)
    Q_PROPERTY(QString serialPort READ serialPort WRITE setSerialPort NOTIFY serialPortChanged)
    Q_PROPERTY(QString serialNumber READ serialNumber WRITE setSerialNumber NOTIFY serialNumberChanged)
    Q_PROPERTY(bool hardwareRecognized READ hardwareRecognized WRITE setHardwareRecognized NOTIFY hardwareRecognizedChanged)
    Q_PROPERTY(QString backend READ backend WRITE setBackend NOTIFY backendChanged)
    Q_PROPERTY(qint32 baudRate READ baudRate WRITE setBaudRate NOTIFY baudRateChanged)

public:
    explicit ZigbeeAdapter(QObject *parent = nullptr);

    QString name() const;
    void setName(const QString &name);

    QString description() const;
    void setDescription(const QString &description);

    QString serialPort() const;
    void setSerialPort(const QString &serialPort);

    QString serialNumber() const;
    void setSerialNumber(const QString &serialNumber);

    bool hardwareRecognized() const;
    void setHardwareRecognized(bool hardwareRecognized);

    QString backend() const;
    void setBackend(const QString &backend);

    qint32 baudRate() const;
    void setBaudRate(qint32 baudRate);

    bool operator==(const ZigbeeAdapter &other) const;

private:
    QString m_name;
    QString m_description;
    QString m_serialPort;
    QString m_serialNumber;
    bool m_hardwareRecognized = false;
    QString m_backend;
    qint32 m_baudRate = 38400;

signals:
    void nameChanged();
    void descriptionChanged();
    void serialPortChanged();
    void serialNumberChanged();
    void hardwareRecognizedChanged();
    void backendChanged();
    void baudRateChanged();
};

QDebug operator<<(QDebug debug, const ZigbeeAdapter &adapter);

#endif // ZIGBEEADAPTER_H
