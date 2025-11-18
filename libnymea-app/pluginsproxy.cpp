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

#include "pluginsproxy.h"

PluginsProxy::PluginsProxy(QObject *parent) :
    QSortFilterProxyModel(parent)
{

}

Plugins *PluginsProxy::plugins()
{
    return m_plugins;
}

void PluginsProxy::setPlugins(Plugins *plugins)
{
    m_plugins = plugins;
    setSourceModel(plugins);
    setSortRole(Plugins::NameRole);
    sort(0);
}

bool PluginsProxy::showOnlyConfigurable() const
{
    return m_showOnlyConfigurable;
}

void PluginsProxy::setShowOnlyConfigurable(bool showOnlyConfigurable)
{
    if (m_showOnlyConfigurable != showOnlyConfigurable) {
        m_showOnlyConfigurable = showOnlyConfigurable;
        emit showOnlyConfigurableChanged();
    }
}

QString PluginsProxy::filter() const
{
    return m_filter;
}

void PluginsProxy::setFilter(const QString &filter)
{
    if (m_filter != filter) {
        m_filter = filter;
        emit filterChanged();
        invalidateFilter();
    }
}

Plugin *PluginsProxy::get(int index) const
{
    return m_plugins->get(mapToSource(this->index(index, 0)).row());
}

bool PluginsProxy::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    Q_UNUSED(source_parent)

    Plugin *plugin = m_plugins->get(source_row);
    if (m_showOnlyConfigurable) {
        if (plugin->paramTypes()->rowCount() == 0) {
            return false;
        }
    }

    if (!m_filter.isEmpty()) {
        if (!plugin->name().toLower().contains(m_filter.toLower())) {
            return false;
        }
    }
    return true;
}
