/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of guh-control                                       *
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

#ifndef DEVICECLASS_H
#define DEVICECLASS_H

#include <QObject>
#include <QUuid>
#include <QList>
#include <QString>

#include "paramtypes.h"
#include "statetypes.h"
#include "eventtypes.h"
#include "actiontypes.h"

class DeviceClass : public QObject
{
    Q_OBJECT
    Q_ENUMS(SetupMethod)

    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QUuid id READ id CONSTANT)
    Q_PROPERTY(QUuid vendorId READ vendorId CONSTANT)
    Q_PROPERTY(QStringList createMethods READ createMethods CONSTANT)
    Q_PROPERTY(SetupMethod setupMethod READ setupMethod CONSTANT)
    Q_PROPERTY(ParamTypes *paramTypes READ paramTypes NOTIFY paramTypesChanged)
    Q_PROPERTY(ParamTypes *discoveryParamTypes READ discoveryParamTypes NOTIFY discoveryParamTypesChanged)
    Q_PROPERTY(StateTypes *stateTypes READ stateTypes NOTIFY stateTypesChanged)
    Q_PROPERTY(EventTypes *eventTypes READ eventTypes NOTIFY eventTypesChanged)
    Q_PROPERTY(ActionTypes *actionTypes READ actionTypes NOTIFY actionTypesChanged)

public:

    enum SetupMethod {
        SetupMethodJustAdd,
        SetupMethodDisplayPin,
        SetupMethodEnterPin,
        SetupMethodPushButton
    };

    DeviceClass(QObject *parent = 0);

    QString name() const;
    void setName(const QString &name);

    QUuid id() const;
    void setId(const QUuid &id);

    QUuid vendorId() const;
    void setVendorId(const QUuid &vendorId);

    QUuid pluginId() const;
    void setPluginId(const QUuid &pluginId);

    QStringList createMethods() const;
    void setCreateMethods(const QStringList &createMethods);

    SetupMethod setupMethod() const;
    void setSetupMethod(SetupMethod setupMethod);

    ParamTypes *paramTypes() const;
    void setParamTypes(ParamTypes *paramTypes);

    ParamTypes *discoveryParamTypes() const;
    void setDiscoveryParamTypes(ParamTypes *paramTypes);

    StateTypes *stateTypes() const;
    void setStateTypes(StateTypes *stateTypes);

    EventTypes *eventTypes() const;
    void setEventTypes(EventTypes *eventTypes);

    ActionTypes *actionTypes() const;
    void setActionTypes(ActionTypes *actionTypes);

    Q_INVOKABLE bool hasActionType(const QUuid &actionTypeId);

private:
    QUuid m_id;
    QUuid m_vendorId;
    QUuid m_pluginId;
    QString m_name;
    QStringList m_createMethods;
    SetupMethod m_setupMethod;

    ParamTypes *m_paramTypes;
    ParamTypes *m_discoveryParamTypes;
    StateTypes *m_stateTypes;
    EventTypes *m_eventTypes;
    ActionTypes *m_actionTypes;

signals:
    void paramTypesChanged();
    void discoveryParamTypesChanged();
    void stateTypesChanged();
    void eventTypesChanged();
    void actionTypesChanged();

};

#endif // DEVICECLASS_H
