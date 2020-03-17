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
