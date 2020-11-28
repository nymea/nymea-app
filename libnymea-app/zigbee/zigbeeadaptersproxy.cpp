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

#include "zigbeemanager.h"
#include "zigbeeadapters.h"
#include "zigbeenetworks.h"

ZigbeeAdaptersProxy::ZigbeeAdaptersProxy(QObject *parent) : QSortFilterProxyModel(parent)
{

}

ZigbeeManager *ZigbeeAdaptersProxy::manager() const
{
    return m_manager;
}

void ZigbeeAdaptersProxy::setManager(ZigbeeManager *manager)
{
    if (m_manager != manager) {
        m_manager = manager;
        connect(m_manager->adapters(), &ZigbeeAdapters::countChanged, this, [this](){
            emit countChanged();
        });
        connect(m_manager->networks(), &ZigbeeNetworks::countChanged, this, [this]() {
            invalidateFilter();
        });
        setSourceModel(m_manager->adapters());
        setSortRole(ZigbeeAdapters::RoleSerialPort);
        sort(0, Qt::DescendingOrder);
        invalidateFilter();
        emit countChanged();
    }
}

ZigbeeAdaptersProxy::HardwareFilter ZigbeeAdaptersProxy::hardwareFilter() const
{
    return m_hardwareFilter;
}

void ZigbeeAdaptersProxy::setHardwareFilter(ZigbeeAdaptersProxy::HardwareFilter hardwareFilter)
{
    if (m_hardwareFilter != hardwareFilter) {
        m_hardwareFilter = hardwareFilter;
        emit hardwareFilterChanged(m_hardwareFilter);

        invalidateFilter();
        emit countChanged();
    }
}

bool ZigbeeAdaptersProxy::onlyUnused() const
{
    return m_onlyUnused;
}

void ZigbeeAdaptersProxy::setOnlyUnused(bool onlyUnused)
{
    if (m_onlyUnused != onlyUnused) {
        m_onlyUnused = onlyUnused;
        emit onlyUnusedChanged();

        invalidateFilter();
        emit countChanged();
    }
}

ZigbeeAdapter *ZigbeeAdaptersProxy::get(int index) const
{
    if (index >= 0 && index < m_manager->adapters()->rowCount()) {
        return m_manager->adapters()->get(mapToSource(this->index(index, 0)).row());
    }
    return nullptr;
}

bool ZigbeeAdaptersProxy::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    Q_UNUSED(source_parent)

    ZigbeeAdapter *adapter = m_manager->adapters()->get(source_row);

    if (m_hardwareFilter == HardwareFilterRecognized && !adapter->hardwareRecognized()) {
        return false;
    }

    if (m_hardwareFilter == HardwareFilterUnrecognized && adapter->hardwareRecognized()) {
        return false;
    }

    if (m_onlyUnused) {
        if (m_manager->networks()->findBySerialPort(adapter->serialPort()) != nullptr) {
            return false;
        }
    }

    return true;
}
