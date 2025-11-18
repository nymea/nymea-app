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

#include "interfacesproxy.h"

#include "types/interface.h"
#include "types/interfaces.h"
#include "types/thing.h"

#include "things.h"
#include "thingsproxy.h"

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

    if (m_thingsFilter != nullptr) {
        // TODO: This could be improved *a lot* by caching interfaces in the devices model...
        bool found = false;
        for (int i = 0; i < m_thingsFilter->rowCount(); i++) {
            Thing *d = m_thingsFilter->get(i);
            if (!d->thingClass()) {
                qWarning() << "Cannot find ThingClass for thing:" << d->id() << d->name();
                return false;
            }
            if (d->thingClass()->interfaces().contains(interfaceName)) {
                found = true;
                break;
            }
        }
        if (!found) {
            return false;
        }
    }
    if (m_thingsProxyFilter != nullptr) {
        // TODO: This could be improved *a lot* by caching interfaces in the devices model...
        bool found = false;
        for (int i = 0; i < m_thingsProxyFilter->rowCount(); i++) {
            Thing *d = m_thingsProxyFilter->get(i);
            if (!d->thingClass()) {
                qWarning() << "Cannot find ThingClass for thing:" << d->id() << d->name();
                return false;
            }
            if (d->thingClass()->interfaces().contains(interfaceName)) {
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
