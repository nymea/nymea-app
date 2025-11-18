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

QString ZigbeeAdaptersProxy::serialPortFilter() const
{
    return m_serialPortFilter;
}

void ZigbeeAdaptersProxy::setSerialPortFilter(const QString &serialPortFilter)
{
    if (m_serialPortFilter != serialPortFilter) {
        m_serialPortFilter = serialPortFilter;
        emit serialPortFilterChanged();
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

    if (!m_serialPortFilter.isEmpty() && m_serialPortFilter != adapter->serialPort()) {
        return false;
    }

    return true;
}
