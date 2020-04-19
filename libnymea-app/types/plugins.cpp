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
    return m_plugins.count();
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
    return m_plugins.count();
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
    beginInsertRows(QModelIndex(), m_plugins.count(), m_plugins.count());
    //qDebug() << "Plugin: loaded plugin" << plugin->name();
    m_plugins.append(plugin);
    endInsertRows();
}

void Plugins::clearModel()
{
    beginResetModel();
    qDeleteAll(m_plugins);
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

