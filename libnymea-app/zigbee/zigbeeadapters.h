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

#ifndef ZIGBEEADAPTERS_H
#define ZIGBEEADAPTERS_H

#include <QObject>
#include <QAbstractListModel>

#include "zigbeeadapter.h"

class ZigbeeAdapters : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        RoleName,
        RoleDescription,
        RoleSerialPort,
        RoleHardwareRecognized,
        RoleBackend,
        RoleBaudRate
    };
    Q_ENUM(Roles)

    explicit ZigbeeAdapters(QObject *parent = nullptr);
    virtual ~ZigbeeAdapters() override = default;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addAdapter(ZigbeeAdapter *adapter);
    void removeAdapter(const QString &serialPort);

    void clear();

    Q_INVOKABLE virtual ZigbeeAdapter *get(int index) const;

signals:
    void countChanged();

protected:
    QList<ZigbeeAdapter *> m_adapters;

};

#endif // ZIGBEEADAPTERS_H
