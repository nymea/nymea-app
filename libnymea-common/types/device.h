/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of mea                                       *
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

class Device : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid id READ id CONSTANT)
    Q_PROPERTY(QUuid deviceClassId READ deviceClassId CONSTANT)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(bool setupComplete READ setupComplete NOTIFY setupCompleteChanged)
    Q_PROPERTY(Params *params READ params NOTIFY paramsChanged)
    Q_PROPERTY(States *states READ states NOTIFY statesChanged)

public:
    explicit Device(QObject *parent = 0);

    QString name() const;
    void setName(const QString &name);

    QUuid id() const;
    void setId(const QUuid &id);

    QUuid deviceClassId() const;
    void setDeviceClassId(const QUuid &deviceClassId);

    bool setupComplete();
    void setSetupComplete(const bool &setupComplete);

    Params *params() const;
    void setParams(Params *params);

    States *states() const;
    void setStates(States *states);

    Q_INVOKABLE bool hasState(const QUuid &stateTypeId);

    Q_INVOKABLE QVariant stateValue(const QUuid &stateTypeId);
    void setStateValue(const QUuid &stateTypeId, const QVariant &value);

private:
    QString m_name;
    QUuid m_id;
    QUuid m_deviceClassId;
    bool m_setupComplete;
    Params *m_params = nullptr;
    States *m_states = nullptr;

signals:
    void nameChanged();
    void setupCompleteChanged();
    void paramsChanged();
    void statesChanged();

};

#endif // DEVICE_H
