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

#include "zigbeeadaptersproxy.h"

#include "zigbeeadapters.h"

ZigbeeAdaptersProxy::ZigbeeAdaptersProxy(QObject *parent) : QSortFilterProxyModel(parent)
{

}

ZigbeeAdapters *ZigbeeAdaptersProxy::adapters() const
{
    return m_adapters;
}

void ZigbeeAdaptersProxy::setAdapters(ZigbeeAdapters *adapters)
{
    m_adapters = adapters;
    emit adaptersChanged();

    setSourceModel(m_adapters);
    connect(m_adapters, &ZigbeeAdapters::countChanged, this, &ZigbeeAdaptersProxy::countChanged);
    setSortRole(ZigbeeAdapters::RoleSystemLocation);
    sort(0, Qt::DescendingOrder);
    invalidateFilter();
}

ZigbeeAdaptersProxy::HardwareFilter ZigbeeAdaptersProxy::hardwareFilter() const
{
    return m_hardwareFilter;
}

void ZigbeeAdaptersProxy::setHardwareFilter(ZigbeeAdaptersProxy::HardwareFilter hardwareFilter)
{
    m_hardwareFilter = hardwareFilter;
    emit hardwareFilterChanged(m_hardwareFilter);
    invalidateFilter();
}

ZigbeeAdapter *ZigbeeAdaptersProxy::get(int index) const
{
    return m_adapters->get(mapToSource(this->index(index, 0)).row());
}

bool ZigbeeAdaptersProxy::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    Q_UNUSED(source_parent)

    ZigbeeAdapter *adapter = m_adapters->get(source_row);

    if (m_hardwareFilter == HardwareFilterRecognized) {
        if (adapter->hardwareRecognized() == false) {
            return true;
        }
    }

    if (m_hardwareFilter == HardwareFilterUnrecognized) {
        if (adapter->hardwareRecognized() == true) {
            return true;
        }
    }

    return false;
}
