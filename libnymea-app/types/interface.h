// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef INTERFACE_H
#define INTERFACE_H

#include <QObject>

class EventTypes;
class StateTypes;
class ActionTypes;
class ThingClass;

class Interface : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString displayName READ displayName CONSTANT)
    Q_PROPERTY(EventTypes* eventTypes READ eventTypes CONSTANT)
    Q_PROPERTY(StateTypes* stateTypes READ stateTypes CONSTANT)
    Q_PROPERTY(ActionTypes* actionTypes READ actionTypes CONSTANT)

public:
    explicit Interface(const QString &name, const QString &displayName, QObject *parent = nullptr);

    QString name() const;
    QString displayName() const;
    EventTypes* eventTypes() const;
    StateTypes* stateTypes() const;
    ActionTypes* actionTypes() const;

    ThingClass* createThingClass();

private:
    QString m_name;
    QString m_displayName;
    EventTypes* m_eventTypes = nullptr;
    StateTypes* m_stateTypes = nullptr;
    ActionTypes* m_actionTypes = nullptr;
};

#endif // INTERFACE_H
