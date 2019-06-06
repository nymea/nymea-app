/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of nymea:app                                         *
 *                                                                         *
 *  This library is free software; you can redistribute it and/or          *
 *  modify it under the terms of the GNU Lesser General Public             *
 *  License as published by the Free Software Foundation; either           *
 *  version 2.1 of the License, or (at your option) any later version.     *
 *                                                                         *
 *  This library is distributed in the hope that it will be useful,        *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU      *
 *  Lesser General Public License for more details.                        *
 *                                                                         *
 *  You should have received a copy of the GNU Lesser General Public       *
 *  License along with this library; If not, see                           *
 *  <http://www.gnu.org/licenses/>.                                        *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

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
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(bool setupComplete READ setupComplete NOTIFY setupCompleteChanged)
    Q_PROPERTY(Params *params READ params NOTIFY paramsChanged)
    Q_PROPERTY(Params *settings READ settings NOTIFY settingsChanged)
    Q_PROPERTY(States *states READ states NOTIFY statesChanged)
    Q_PROPERTY(DeviceClass *deviceClass READ deviceClass CONSTANT)

public:
    explicit Device(DeviceClass *deviceClass, QObject *parent = nullptr);

    QString name() const;
    void setName(const QString &name);

    QUuid id() const;
    void setId(const QUuid &id);

    QUuid deviceClassId() const;

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

};

QDebug operator<<(QDebug &dbg, Device* device);

#endif // DEVICE_H
