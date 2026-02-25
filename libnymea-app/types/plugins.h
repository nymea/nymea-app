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

#ifndef PLUGINS_H
#define PLUGINS_H

#include <QObject>
#include <QAbstractListModel>

#include "plugin.h"

class Plugins : public QAbstractListModel
{
    Q_OBJECT
public:
    enum StateRole {
        NameRole = Qt::DisplayRole,
        PluginIdRole
    };

    explicit Plugins(QObject *parent = 0);

    QList<Plugin *> plugins();

    Q_INVOKABLE int count() const;
    Q_INVOKABLE Plugin *get(int index) const;
    Q_INVOKABLE Plugin *getPlugin(const QUuid &pluginId) const;

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

    void addPlugin(Plugin *plugin);

    void clearModel();

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    QList<Plugin *> m_plugins;

};

#endif // PLUGINS_H
