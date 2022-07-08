/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2021, nymea GmbH
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

#include "serialportsproxy.h"

SerialPortsProxy::SerialPortsProxy(QObject *parent) : QSortFilterProxyModel(parent)
{

}

SerialPorts *SerialPortsProxy::serialPorts() const
{
    return m_serialPorts;
}

void SerialPortsProxy::setSerialPorts(SerialPorts *serialPorts)
{
    if (m_serialPorts == serialPorts)
        return;

    setSourceModel(serialPorts);
    m_serialPorts = serialPorts;
    emit serialPortsChanged();

    connect(m_serialPorts, &SerialPorts::countChanged, this, [this](){
        emit countChanged();
    });
    connect(m_serialPorts, &SerialPorts::countChanged, this, [this]() {
        sort(0, Qt::DescendingOrder);
    });

    setSortRole(SerialPorts::RoleSystemLocation);
    sort(0, Qt::DescendingOrder);
    emit countChanged();
}

SerialPort *SerialPortsProxy::get(int index) const
{
    if (index >= 0 && index < m_serialPorts->rowCount()) {
        return m_serialPorts->get(mapToSource(this->index(index, 0)).row());
    }
    return nullptr;
}

QString SerialPortsProxy::systemLocationFilter() const
{
    return m_systemLocationFilter;
}

void SerialPortsProxy::setSystemLocationFilter(const QString &systemLocationFilter)
{
    if (m_systemLocationFilter != systemLocationFilter) {
        m_systemLocationFilter = systemLocationFilter;
        emit systemLocationFilterChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool SerialPortsProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    Q_UNUSED(sourceParent)
    if (!m_serialPorts) {
        return false;
    }

    if (!m_systemLocationFilter.isEmpty()) {
        SerialPort *serialPort = m_serialPorts->get(sourceRow);
        if (serialPort->systemLocation() != m_systemLocationFilter) {
            return false;
        }
    }
    return true;
}

