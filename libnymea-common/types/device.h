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

class Device : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid id READ id CONSTANT)
    Q_PROPERTY(QUuid deviceClassId READ deviceClassId CONSTANT)
    Q_PROPERTY(QUuid parentDeviceId READ parentDeviceId CONSTANT)
    Q_PROPERTY(bool isChild READ isChild CONSTANT)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(bool setupComplete READ setupComplete NOTIFY setupCompleteChanged)
    Q_PROPERTY(Params *params READ params NOTIFY paramsChanged)
    Q_PROPERTY(Params *settings READ settings NOTIFY settingsChanged)
    Q_PROPERTY(States *states READ states NOTIFY statesChanged)
    Q_PROPERTY(DeviceClass *deviceClass READ deviceClass CONSTANT)

public:
    explicit Device(DeviceClass *deviceClass, const QUuid &parentDeviceId = QUuid(), QObject *parent = nullptr);

    QString name() const;
    void setName(const QString &name);

    QUuid id() const;
    void setId(const QUuid &id);

    QUuid deviceClassId() const;
    QUuid parentDeviceId() const;
    bool isChild() const;

    bool setupComplete();
    void setSetupComplete(const bool &setupComplete);

    Params *params() const;
    void setParams(Params *params);

    Params *settings() const;
    void setSettings(Params *settings);

    States *states() const;
    void setStates(States *states);

    DeviceClass *deviceClass() const;

    Q_INVOKABLE bool hasState(const QUuid &stateTypeId);

    Q_INVOKABLE QVariant stateValue(const QUuid &stateTypeId);
    void setStateValue(const QUuid &stateTypeId, const QVariant &value);

private:
    QString m_name;
    QUuid m_id;
    QUuid m_parentDeviceId;
    bool m_setupComplete;
    Params *m_params = nullptr;
    Params *m_settings = nullptr;
    States *m_states = nullptr;
    DeviceClass *m_deviceClass = nullptr;


signals:
    void nameChanged();
    void setupCompleteChanged();
    void paramsChanged();
    void settingsChanged();
    void statesChanged();
    void eventTriggered(const QString &eventTypeId, const QVariantMap &params);

};

QDebug operator<<(QDebug &dbg, Device* device);

#endif // DEVICE_H
