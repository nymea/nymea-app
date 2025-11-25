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

#include "plugins.h"

#include <QDebug>

Plugins::Plugins(QObject *parent) :
    QAbstractListModel(parent)
{

}

QList<Plugin *> Plugins::plugins()
{
    return m_plugins;
}

int Plugins::count() const
{
    return static_cast<int>(m_plugins.count());
}

Plugin *Plugins::get(int index) const
{
    if (index < 0 || index >= m_plugins.count()) {
        return nullptr;
    }
    return m_plugins.at(index);
}

Plugin *Plugins::getPlugin(const QUuid &pluginId) const
{
    foreach (Plugin *plugin, m_plugins) {
        if (plugin->pluginId() == pluginId) {
            return plugin;
        }
    }
    return 0;
}

int Plugins::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return static_cast<int>(m_plugins.count());
}

QVariant Plugins::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_plugins.count())
        return QVariant();

    Plugin *plugin = m_plugins.at(index.row());
    if (role == NameRole) {
        return plugin->name();
    } else if (role == PluginIdRole) {
        return plugin->pluginId();
    }
    return QVariant();
}

void Plugins::addPlugin(Plugin *plugin)
{
    beginInsertRows(QModelIndex(), static_cast<int>(m_plugins.count()), static_cast<int>(m_plugins.count()));
    //qDebug() << "Plugin: loaded plugin" << plugin->name();
    m_plugins.append(plugin);
    endInsertRows();
}

void Plugins::clearModel()
{
    beginResetModel();
    foreach (Plugin *plugin, m_plugins)
        plugin->deleteLater();

    m_plugins.clear();
    endResetModel();
}

QHash<int, QByteArray> Plugins::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[PluginIdRole] = "pluginId";
    return roles;
}

