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
    connect(m_adapters, &ZigbeeAdapters::countChanged, this, [this](){
        invalidateFilter();
        emit countChanged();
    });

    setSourceModel(m_adapters);
    setSortRole(ZigbeeAdapters::RoleSerialPort);
    sort(0, Qt::DescendingOrder);
    invalidateFilter();
    emit countChanged();
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
    emit countChanged();
}

ZigbeeAdapter *ZigbeeAdaptersProxy::get(int index) const
{
    return m_adapters->get(mapToSource(this->index(index, 0)).row());
}

bool ZigbeeAdaptersProxy::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    Q_UNUSED(source_parent)

    ZigbeeAdapter *adapter = m_adapters->get(source_row);
    if (!adapter)
        return false;

    if (m_hardwareFilter == HardwareFilterRecognized) {
        return adapter->hardwareRecognized();
    } else if (m_hardwareFilter == HardwareFilterUnrecognized) {
        return !adapter->hardwareRecognized();
    }

    return true;
}
