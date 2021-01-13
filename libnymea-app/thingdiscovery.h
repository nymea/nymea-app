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

#ifndef THINGDISCOVERY_H
#define THINGDISCOVERY_H

#include <QAbstractListModel>
#include <QUuid>

#include "engine.h"

class DeviceDescriptor: public QObject {
    Q_OBJECT
    Q_PROPERTY(QUuid id READ id CONSTANT)
    Q_PROPERTY(QUuid deviceId READ deviceId CONSTANT)
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString description READ description CONSTANT)
    Q_PROPERTY(Params* params READ params CONSTANT)
public:
    DeviceDescriptor(const QUuid &id, const QUuid &deviceId, const QString &name, const QString &description, QObject *parent = nullptr);

    QUuid id() const;
    QUuid deviceId() const;
    QString name() const;
    QString description() const;
    Params* params() const;

private:
    QUuid m_id;
    QUuid m_deviceId;
    QString m_name;
    QString m_description;
    Params *m_params = nullptr;
};

class ThingDiscovery : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(QString displayMessage READ displayMessage NOTIFY busyChanged)
public:
    enum Roles {
        RoleId,
        RoleDeviceId,
        RoleName,
        RoleDescription
    };

    ThingDiscovery(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;


    Q_INVOKABLE void discoverThings(const QUuid &thingClassId, const QVariantList &discoveryParams = {});

    Q_INVOKABLE DeviceDescriptor* get(int index) const;

    Engine* engine() const;
    void setEngine(Engine *jsonRpcClient);

    bool busy() const;
    QString displayMessage() const;

private slots:
    void discoverThingsResponse(int commandId, const QVariantMap &params);

signals:
    void busyChanged();
    void countChanged();
    void engineChanged();

private:
    Engine *m_engine = nullptr;
    bool m_busy = false;
    QString m_displayMessage;

    bool contains(const QUuid &deviceDescriptorId) const;
    QList<DeviceDescriptor*> m_foundDevices;
};

class DeviceDiscoveryProxy: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(ThingDiscovery* deviceDiscovery READ deviceDiscovery WRITE setDeviceDiscovery NOTIFY deviceDiscoveryChanged)
    Q_PROPERTY(bool showAlreadyAdded READ showAlreadyAdded WRITE setShowAlreadyAdded NOTIFY showAlreadyAddedChanged)
    Q_PROPERTY(bool showNew READ showNew WRITE setShowNew NOTIFY showNewChanged)
    Q_PROPERTY(QUuid filterDeviceId READ filterDeviceId WRITE setFilterDeviceId NOTIFY filterDeviceIdChanged)

public:
    DeviceDiscoveryProxy(QObject *parent = nullptr);

    ThingDiscovery* deviceDiscovery() const;
    void setDeviceDiscovery(ThingDiscovery* deviceDiscovery);

    bool showAlreadyAdded() const;
    void setShowAlreadyAdded(bool showAlreadyAdded);

    bool showNew() const;
    void setShowNew(bool showNew);

    QUuid filterDeviceId() const;
    void setFilterDeviceId(const QUuid &filterDeviceId);

    Q_INVOKABLE DeviceDescriptor* get(int index) const;

signals:
    void countChanged();
    void deviceDiscoveryChanged();
    void showAlreadyAddedChanged();
    void showNewChanged();
    void filterDeviceIdChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    ThingDiscovery* m_deviceDiscovery = nullptr;
    bool m_showAlreadyAdded = false;
    bool m_showNew = true;
    QUuid m_filterDeviceId;
};

#endif // THINGDISCOVERY_H
