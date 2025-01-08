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

class ThingDescriptor: public QObject {
    Q_OBJECT
    Q_PROPERTY(QUuid id READ id CONSTANT)
    Q_PROPERTY(QUuid thingClassId READ thingClassId CONSTANT)
    Q_PROPERTY(QUuid thingId READ thingId CONSTANT)
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString description READ description CONSTANT)
    Q_PROPERTY(Params* params READ params CONSTANT)
public:
    ThingDescriptor(const QUuid &id, const QUuid &thingClassId, const QUuid &thingId, const QString &name, const QString &description, QObject *parent = nullptr);

    QUuid id() const;
    QUuid thingClassId() const;
    QUuid thingId() const;
    QString name() const;
    QString description() const;
    Params *params() const;

private:
    QUuid m_id;
    QUuid m_thingClassId;
    QUuid m_thingId;
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
        RoleThingId,
        RoleName,
        RoleDescription
    };

    ThingDiscovery(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;


    Q_INVOKABLE int discoverThings(const QUuid &thingClassId, const QVariantList &discoveryParams = {});
    Q_INVOKABLE QList<int> discoverThingsByInterface(const QString &interfaceName);

    Q_INVOKABLE ThingDescriptor* get(int index) const;

    Engine* engine() const;
    void setEngine(Engine *jsonRpcClient);

    bool busy() const;
    QString displayMessage() const;

signals:
    void busyChanged();
    void countChanged();
    void engineChanged();
    void discoverThingsReply(int commandId, Thing::ThingError thingError, const QString &displayMessage);

private slots:
    int discoverThingsInternal(const QUuid &thingClassId, const QVariantList &discoveryParams = {});
    void discoverThingsResponse(int commandId, const QVariantMap &params);

private:
    Engine *m_engine = nullptr;
    QString m_displayMessage;
    QList<int> m_pendingRequests;

    bool contains(const QUuid &deviceDescriptorId) const;
    QList<ThingDescriptor*> m_foundThings;
};

class ThingDiscoveryProxy: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(ThingDiscovery* thingDiscovery READ thingDiscovery WRITE setThingDiscovery NOTIFY thingDiscoveryChanged)
    Q_PROPERTY(bool showAlreadyAdded READ showAlreadyAdded WRITE setShowAlreadyAdded NOTIFY showAlreadyAddedChanged)
    Q_PROPERTY(bool showNew READ showNew WRITE setShowNew NOTIFY showNewChanged)
    Q_PROPERTY(QUuid filterThingId READ filterThingId WRITE setFilterThingId NOTIFY filterThingIdChanged)

public:
    ThingDiscoveryProxy(QObject *parent = nullptr);

    ThingDiscovery* thingDiscovery() const;
    void setThingDiscovery(ThingDiscovery* thingDiscovery);

    bool showAlreadyAdded() const;
    void setShowAlreadyAdded(bool showAlreadyAdded);

    bool showNew() const;
    void setShowNew(bool showNew);

    QUuid filterThingId() const;
    void setFilterThingId(const QUuid &filterThingId);

    Q_INVOKABLE ThingDescriptor* get(int index) const;

signals:
    void countChanged();
    void thingDiscoveryChanged();
    void showAlreadyAddedChanged();
    void showNewChanged();
    void filterThingIdChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    ThingDiscovery* m_thingDiscovery = nullptr;
    bool m_showAlreadyAdded = false;
    bool m_showNew = true;
    QUuid m_filterThingId;
};

#endif // THINGDISCOVERY_H
