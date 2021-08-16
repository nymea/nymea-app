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

#ifndef INTERFACESPROXY_H
#define INTERFACESPROXY_H

#include <QSortFilterProxyModel>

#include "things.h"
#include "thingsproxy.h"
class Interface;
class Interfaces;

class InterfacesProxy: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

    Q_PROPERTY(QStringList shownInterfaces READ shownInterfaces WRITE setShownInterfaces NOTIFY shownInterfacesChanged)
    Q_PROPERTY(Things* thingsFilter READ thingsFilter WRITE setThingsFilter NOTIFY thingsFilterChanged)
    Q_PROPERTY(ThingsProxy* thingsProxyFilter READ thingsProxyFilter WRITE setThingsProxyFilter NOTIFY thingsProxyFilterChanged)
    Q_PROPERTY(bool showEvents READ showEvents WRITE setShowEvents NOTIFY showEventsChanged)
    Q_PROPERTY(bool showActions READ showActions WRITE setShowActions NOTIFY showActionsChanged)
    Q_PROPERTY(bool showStates READ showStates WRITE setShowStates NOTIFY showStatesChanged)

public:
    InterfacesProxy(QObject *parent = nullptr);

    QStringList shownInterfaces() const { return m_shownInterfaces; }
    void setShownInterfaces(const QStringList &shownInterfaces) { m_shownInterfaces = shownInterfaces; emit shownInterfacesChanged(); invalidateFilter(); }

    Things* thingsFilter() const { return m_thingsFilter; }
    void setThingsFilter(Things *things) { m_thingsFilter = things; emit thingsFilterChanged(); invalidateFilter(); }

    ThingsProxy* thingsProxyFilter() const { return m_thingsProxyFilter; }
    void setThingsProxyFilter(ThingsProxy *thingsProxy) { m_thingsProxyFilter = thingsProxy; emit thingsProxyFilterChanged(); invalidateFilter(); }

    bool showEvents() const;
    void setShowEvents(bool showEvents);

    bool showActions() const;
    void setShowActions(bool showActions);

    bool showStates() const;
    void setShowStates(bool showStates);

    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

    Q_INVOKABLE Interface* get(int index) const;
    Q_INVOKABLE Interface* getInterface(const QString &name) const;

signals:
    void shownInterfacesChanged();
    void thingsFilterChanged();
    void thingsProxyFilterChanged();
    void showEventsChanged();
    void showActionsChanged();
    void showStatesChanged();

    void countChanged();

private:
    Interfaces *m_interfaces = nullptr;
    QStringList m_shownInterfaces;
    Things* m_thingsFilter = nullptr;
    ThingsProxy* m_thingsProxyFilter = nullptr;
    bool m_showEvents = false;
    bool m_showActions = false;
    bool m_showStates = false;
};

#endif // INTERFACESPROXY_H
