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

    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString displayName READ displayName CONSTANT)
    Q_PROPERTY(QUuid id READ id CONSTANT)
    Q_PROPERTY(QUuid vendorId READ vendorId CONSTANT)
    Q_PROPERTY(QStringList createMethods READ createMethods CONSTANT)
    Q_PROPERTY(SetupMethod setupMethod READ setupMethod CONSTANT)
    Q_PROPERTY(QStringList basicTags READ basicTagNames CONSTANT)
    Q_PROPERTY(QStringList interfaces READ interfaces CONSTANT)
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
    Q_ENUM(SetupMethod)

    enum BasicTag {
        BasicTagNone         = 0,
        BasicTagService      = 1 << 0,
        BasicTagDevice       = 1 << 1,
        BasicTagSensor       = 1 << 2,
        BasicTagActuator     = 1 << 3,
        BasicTagLighting     = 1 << 4,
        BasicTagEnergy       = 1 << 5,
        BasicTagMultimedia   = 1 << 6,
        BasicTagWeather      = 1 << 7,
        BasicTagGateway      = 1 << 8,
        BasicTagHeating      = 1 << 9,
        BasicTagCooling      = 1 << 10,
        BasicTagNotification = 1 << 11,
        BasicTagSecurity     = 1 << 12,
        BasicTagTime         = 1 << 13,
        BasicTagShading      = 1 << 14,
        BasicTagAppliance    = 1 << 15,
        BasicTagCamera       = 1 << 16,
        BasicTagLock         = 1 << 17
    };
    Q_ENUM(BasicTag)
    Q_DECLARE_FLAGS(BasicTags, BasicTag)
    Q_FLAGS(BasicTags)

    DeviceClass(QObject *parent = 0);

    QString name() const;
    void setName(const QString &name);

    QString displayName() const;
    void setDisplayName(const QString &displayName);

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

    QList<BasicTag> basicTags() const;
    QStringList basicTagNames() const;
    void setBasicTags(QList<BasicTag> basicTag);

    QStringList interfaces() const;
    void setInterfaces(const QStringList &interfaces);

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

    Q_INVOKABLE bool hasActionType(const QString &actionTypeId);

    static QString basicTagToString(BasicTag basicTag);

private:
    QUuid m_id;
    QUuid m_vendorId;
    QUuid m_pluginId;
    QString m_name;
    QString m_displayName;
    QStringList m_createMethods;
    SetupMethod m_setupMethod;
    QList<BasicTag> m_basicTags;
    QStringList m_interfaces;

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
Q_DECLARE_OPERATORS_FOR_FLAGS(DeviceClass::BasicTags)
Q_DECLARE_METATYPE(DeviceClass::BasicTags)
Q_DECLARE_METATYPE(DeviceClass::BasicTag)
#endif // DEVICECLASS_H
