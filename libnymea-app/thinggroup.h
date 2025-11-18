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

#ifndef THINGGROUP_H
#define THINGGROUP_H

#include <QObject>

#include "types/thing.h"

class ThingsProxy;
class ThingManager;
class ParamType;

class ThingGroup : public Thing
{
    Q_OBJECT
public:
    explicit ThingGroup(ThingManager *thingManager, ThingClass *thingClass, ThingsProxy *things, QObject *parent = nullptr);

    Q_INVOKABLE int executeAction(const QString &actionName, const QVariantList &params) override;

private:
    void syncStates();

    QVariant mapValue(const QVariant &value, ParamType *fromParamType, ParamType *toParamType) const;

private:    
    ThingsProxy* m_things = nullptr;

    int m_idCounter = 0;
    QHash<int, QList<int>> m_pendingGroupActions;
};

#endif // THINGGROUP_H
