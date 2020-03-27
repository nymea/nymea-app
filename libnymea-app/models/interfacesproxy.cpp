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

#include "interfacesproxy.h"

#include "types/interface.h"
#include "types/interfaces.h"
#include "types/device.h"

#include "devices.h"
#include "devicesproxy.h"

InterfacesProxy::InterfacesProxy(QObject *parent): QSortFilterProxyModel(parent)
{
    m_interfaces = new Interfaces(this);
    setSourceModel(m_interfaces);
}

bool InterfacesProxy::showEvents() const
{
    return m_showEvents;
}

void InterfacesProxy::setShowEvents(bool showEvents)
{
    if (m_showEvents != showEvents) {
        m_showEvents = showEvents;
        emit showEventsChanged();
        invalidateFilter();
        void countChanged();
    }
}

bool InterfacesProxy::showActions() const
{
    return m_showActions;
}

void InterfacesProxy::setShowActions(bool showActions)
{
    if (m_showActions != showActions) {
        m_showActions = showActions;
        emit showActionsChanged();
        invalidateFilter();
        void countChanged();
    }
}

bool InterfacesProxy::showStates() const
{
    return m_showStates;
}

void InterfacesProxy::setShowStates(bool showStates)
{
    if (m_showStates != showStates) {
        m_showStates = showStates;
        emit showStatesChanged();
        invalidateFilter();
        void countChanged();
    }
}

bool InterfacesProxy::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    Q_UNUSED(source_parent)
    QString interfaceName = m_interfaces->get(source_row)->name();
    if (!m_shownInterfaces.isEmpty()) {
        if (!m_shownInterfaces.contains(interfaceName)) {
            return false;
        }
    }

    if (m_devicesFilter != nullptr) {
        // TODO: This could be improved *a lot* by caching interfaces in the devices model...
        bool found = false;
        for (int i = 0; i < m_devicesFilter->rowCount(); i++) {
            Device *d = m_devicesFilter->get(i);
            if (!d->deviceClass()) {
                qWarning() << "Cannot find DeviceClass for device:" << d->id() << d->name();
                return false;
            }
            if (d->deviceClass()->interfaces().contains(interfaceName)) {
                found = true;
                break;
            }
        }
        if (!found) {
            return false;
        }
    }
    if (m_devicesProxyFilter != nullptr) {
        // TODO: This could be improved *a lot* by caching interfaces in the devices model...
        bool found = false;
        for (int i = 0; i < m_devicesProxyFilter->rowCount(); i++) {
            Device *d = m_devicesProxyFilter->get(i);
            if (!d->deviceClass()) {
                qWarning() << "Cannot find DeviceClass for device:" << d->id() << d->name();
                return false;
            }
            if (d->deviceClass()->interfaces().contains(interfaceName)) {
                found = true;
                break;
            }
        }
        if (!found) {
            return false;
        }
    }

    Interface* iface = m_interfaces->get(source_row);
    if (m_showEvents) {
        if (iface->eventTypes()->rowCount() > 0) {
            return true;
        }
    }

    if (m_showActions) {
        if (iface->actionTypes()->rowCount() > 0) {
            return true;
        }
    }
    if (m_showStates) {
        if (iface->stateTypes()->rowCount() > 0) {
            return true;
        }
    }

    return false;
}

Interface *InterfacesProxy::get(int index) const
{
    return m_interfaces->get(mapToSource(this->index(index, 0)).row());
}

Interface *InterfacesProxy::getInterface(const QString &name) const
{
    qDebug() << "Getting iface" << name;
    for (int i = 0; i < rowCount(); i++) {
        if (get(i)->name() == name) {
            qDebug() << "checking" << get(i)->name();
            return get(i);
        }
    }
    return nullptr;
}
