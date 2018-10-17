/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of nymea:app                                         *
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
    return true;
}
