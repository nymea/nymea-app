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

#ifndef PLUGIN_H
#define PLUGIN_H

#include <QObject>
#include <QUuid>

#include "params.h"
#include "paramtypes.h"

class Plugin : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QUuid pluginId READ pluginId CONSTANT)
    Q_PROPERTY(ParamTypes *paramTypes READ paramTypes CONSTANT)

public:
    explicit Plugin(QObject *parent = 0);

    QString name() const;
    void setName(const QString &name);

    QUuid pluginId() const;
    void setPluginId(const QUuid pluginId);

    ParamTypes *paramTypes();
    void setParamTypes(ParamTypes *paramTypes);

private:
    QString m_name;
    QUuid m_pluginId;
    ParamTypes *m_paramTypes = nullptr;
};

#endif // PLUGIN_H
