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

#ifndef DEVICE_H
#define DEVICE_H

#include <QObject>
#include <QUuid>

#include "params.h"
#include "states.h"
#include "statesproxy.h"

class DeviceClass;
class DeviceManager;

class Device : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid id READ id CONSTANT)
    Q_PROPERTY(QUuid deviceClassId READ deviceClassId CONSTANT)
    Q_PROPERTY(QUuid thingClassId READ thingClassId CONSTANT)
    Q_PROPERTY(QUuid parentDeviceId READ parentDeviceId CONSTANT)
    Q_PROPERTY(bool isChild READ isChild CONSTANT)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(ThingSetupStatus setupStatus READ setupStatus NOTIFY setupStatusChanged)
    Q_PROPERTY(QString setupDisplayMessage READ setupDisplayMessage NOTIFY setupStatusChanged)
    Q_PROPERTY(Params *params READ params NOTIFY paramsChanged)
    Q_PROPERTY(Params *settings READ settings NOTIFY settingsChanged)
    Q_PROPERTY(States *states READ states NOTIFY statesChanged)
    Q_PROPERTY(DeviceClass *deviceClass READ thingClass CONSTANT)
    Q_PROPERTY(DeviceClass *thingClass READ thingClass CONSTANT)

public:
    enum ThingSetupStatus {
        ThingSetupStatusNone,
        ThingSetupStatusInProgress,
        ThingSetupStatusComplete,
        ThingSetupStatusFailed
    };
    Q_ENUM(ThingSetupStatus)

    explicit Device(DeviceManager *thingManager, DeviceClass *thingClass, const QUuid &parentId = QUuid(), QObject *parent = nullptr);

    QUuid id() const;
    void setId(const QUuid &id);

    QString name() const;
    void setName(const QString &name);

    QUuid deviceClassId() const;
    QUuid thingClassId() const;
    QUuid parentDeviceId() const;
    bool isChild() const;

    Device::ThingSetupStatus setupStatus() const;
    QString setupDisplayMessage() const;
    void setSetupStatus(Device::ThingSetupStatus setupStatus, const QString &displayMessage);

    Params *params() const;
    void setParams(Params *params);

    Params *settings() const;
    void setSettings(Params *settings);

    States *states() const;
    void setStates(States *states);

    DeviceClass *thingClass() const;

    Q_INVOKABLE bool hasState(const QUuid &stateTypeId);
    Q_INVOKABLE State *state(const QUuid &stateTypeId) const;
    Q_INVOKABLE State *stateByName(const QString &stateName) const;

    Q_INVOKABLE QVariant stateValue(const QUuid &stateTypeId);
    void setStateValue(const QUuid &stateTypeId, const QVariant &value);

    Q_INVOKABLE virtual int executeAction(const QString &actionName, const QVariantList &params);

signals:
    void nameChanged();
    void setupStatusChanged();
    void paramsChanged();
    void settingsChanged();
    void statesChanged();
    void eventTriggered(const QUuid &eventTypeId, const QVariantMap &params);

private:

protected:
    DeviceManager *m_thingManager = nullptr;
    QString m_name;
    QUuid m_id;
    QUuid m_parentId;
    ThingSetupStatus m_setupStatus = ThingSetupStatusNone;
    QString m_setupDisplayMessage;
    Params *m_params = nullptr;
    Params *m_settings = nullptr;
    States *m_states = nullptr;
    DeviceClass *m_thingClass = nullptr;
};

QDebug operator<<(QDebug &dbg, Device* thing);

#endif // DEVICE_H
