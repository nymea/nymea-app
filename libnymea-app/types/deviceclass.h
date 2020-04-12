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
    Q_PROPERTY(QUuid pluginId READ pluginId CONSTANT)
    Q_PROPERTY(QStringList createMethods READ createMethods CONSTANT)
    Q_PROPERTY(SetupMethod setupMethod READ setupMethod CONSTANT)
    Q_PROPERTY(QStringList interfaces READ interfaces CONSTANT)
    Q_PROPERTY(QString baseInterface READ baseInterface CONSTANT)
    Q_PROPERTY(bool browsable READ browsable CONSTANT)
    Q_PROPERTY(ParamTypes *paramTypes READ paramTypes NOTIFY paramTypesChanged)
    Q_PROPERTY(ParamTypes *settingsTypes READ settingsTypes NOTIFY settingsTypesChanged)
    Q_PROPERTY(ParamTypes *discoveryParamTypes READ discoveryParamTypes NOTIFY discoveryParamTypesChanged)
    Q_PROPERTY(StateTypes *stateTypes READ stateTypes NOTIFY stateTypesChanged)
    Q_PROPERTY(EventTypes *eventTypes READ eventTypes NOTIFY eventTypesChanged)
    Q_PROPERTY(ActionTypes *actionTypes READ actionTypes NOTIFY actionTypesChanged)
    Q_PROPERTY(ActionTypes *browserItemActionTypes READ browserItemActionTypes NOTIFY browserItemActionTypesChanged)

public:

    enum SetupMethod {
        SetupMethodJustAdd,
        SetupMethodDisplayPin,
        SetupMethodEnterPin,
        SetupMethodPushButton,
        SetupMethodOAuth,
        SetupMethodUserAndPassword,
    };
    Q_ENUM(SetupMethod)

    DeviceClass(QObject *parent = nullptr);

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

    QStringList interfaces() const;
    void setInterfaces(const QStringList &interfaces);

    QString baseInterface() const;

    bool browsable() const;
    void setBrowsable(bool browsable);

    ParamTypes *paramTypes() const;
    void setParamTypes(ParamTypes *paramTypes);

    ParamTypes *settingsTypes() const;
    void setSettingsTypes(ParamTypes *settingsTypes);

    ParamTypes *discoveryParamTypes() const;
    void setDiscoveryParamTypes(ParamTypes *paramTypes);

    StateTypes *stateTypes() const;
    void setStateTypes(StateTypes *stateTypes);

    EventTypes *eventTypes() const;
    void setEventTypes(EventTypes *eventTypes);

    ActionTypes *actionTypes() const;
    void setActionTypes(ActionTypes *actionTypes);

    ActionTypes *browserItemActionTypes() const;
    void setBrowserItemActionTypes(ActionTypes *browserActionTypes);

    Q_INVOKABLE bool hasActionType(const QString &actionTypeId);

signals:
    void paramTypesChanged();
    void settingsTypesChanged();
    void discoveryParamTypesChanged();
    void stateTypesChanged();
    void eventTypesChanged();
    void actionTypesChanged();
    void browserItemActionTypesChanged();

private:
    QUuid m_id;
    QUuid m_vendorId;
    QUuid m_pluginId;
    QString m_name;
    QString m_displayName;
    QStringList m_createMethods;
    SetupMethod m_setupMethod;
    QStringList m_interfaces;
    bool m_browsable = false;

    ParamTypes *m_paramTypes = nullptr;
    ParamTypes *m_settingsTypes = nullptr;
    ParamTypes *m_discoveryParamTypes = nullptr;
    StateTypes *m_stateTypes = nullptr;
    EventTypes *m_eventTypes = nullptr;
    ActionTypes *m_actionTypes = nullptr;
    ActionTypes *m_browserItemActionTypes = nullptr;
};
#endif // DEVICECLASS_H
