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

#include "interfacesmodel.h"

#include "engine.h"
#include "thingsproxy.h"

InterfacesModel::InterfacesModel(QObject *parent):
    QAbstractListModel(parent)
{

}

int InterfacesModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return static_cast<int>(m_interfaces.count());
}

QVariant InterfacesModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleName:
        return m_interfaces.at(index.row());
    }
    return QVariant();
}

QHash<int, QByteArray> InterfacesModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleName, "name");
    return roles;
}

Engine *InterfacesModel::engine() const
{
    return m_engine;
}

void InterfacesModel::setEngine(Engine *engine)
{
    if (m_engine != engine) {

        if (m_engine) {
            disconnect(m_thingClassesCountChangedConnection);
        }

        m_engine = engine;
        emit engineChanged();

        m_thingClassesCountChangedConnection = connect(engine->thingManager()->thingClasses(), &ThingClasses::countChanged, this, [this]() {
            syncInterfaces();
        });

        syncInterfaces();
    }
}

ThingsProxy *InterfacesModel::things() const
{
    return m_thingsProxy;
}

void InterfacesModel::setThings(ThingsProxy *things)
{
    if (m_thingsProxy != things) {
        if (m_thingsProxy) {
            disconnect(m_thingsCountChangedConnection);
        }

        m_thingsProxy = things;
        emit thingsChanged();

        m_thingsCountChangedConnection = connect(things, &ThingsProxy::countChanged, this, [this]() {
            syncInterfaces();
        });
        syncInterfaces();
    }
}

QStringList InterfacesModel::shownInterfaces() const
{
    return m_shownInterfaces;
}

void InterfacesModel::setShownInterfaces(const QStringList &shownInterfaces)
{
    if (m_shownInterfaces != shownInterfaces) {
        m_shownInterfaces = shownInterfaces;
        emit shownInterfacesChanged();

        syncInterfaces();
    }
}

bool InterfacesModel::showUncategorized() const
{
    return m_showUncategorized;
}

void InterfacesModel::setShowUncategorized(bool showUncategorized)
{
    if (m_showUncategorized != showUncategorized) {
        m_showUncategorized = showUncategorized;
        emit showUncategorizedChanged();
        syncInterfaces();
    }
}

QString InterfacesModel::get(int index) const
{
    if (index < 0 || index > m_interfaces.count()) {
        return QString();
    }
    return m_interfaces.at(index);
}

void InterfacesModel::syncInterfaces()
{
    if (!m_engine) {
        return;
    }
    QList<ThingClass*> thingClasses;
    if (m_thingsProxy) {
        for (int i = 0; i < m_thingsProxy->rowCount(); i++) {
            thingClasses << m_engine->thingManager()->thingClasses()->getThingClass(m_thingsProxy->get(i)->thingClassId());
        }
    } else {
        for (int i = 0; i < m_engine->thingManager()->thingClasses()->rowCount(); i++) {
            thingClasses << m_engine->thingManager()->thingClasses()->get(i);
        }
    }

    // qWarning() << "syncing for interfaces:" << m_shownInterfaces;
    QStringList interfacesInSource;
    foreach (ThingClass *dc, thingClasses) {
        // qWarning() << "thing" <<dc->name() << "has interfaces" << dc->interfaces();

        bool isInShownIfaces = false;
        foreach (const QString &interface, dc->interfaces()) {
            if (!m_shownInterfaces.isEmpty() && !m_shownInterfaces.contains(interface)) {
                continue;
            }

            if (!interfacesInSource.contains(interface)) {
                interfacesInSource.append(interface);
            }
            // qWarning() << "yes" << interface;
            isInShownIfaces = true;
        }
        if (m_showUncategorized && !isInShownIfaces && !interfacesInSource.contains("uncategorized")) {
            interfacesInSource.append("uncategorized");
        }
    }
    QStringList interfacesToAdd = interfacesInSource;
    QStringList interfacesToRemove;

    foreach (const QString &interface, m_interfaces) {
        if (!interfacesInSource.contains(interface)) {
            interfacesToRemove.append(interface);
        }
        interfacesToAdd.removeAll(interface);
    }
    foreach (const QString &interface, interfacesToRemove) {
        int idx = static_cast<int>(m_interfaces.indexOf(interface));
        beginRemoveRows(QModelIndex(), idx, idx);
        m_interfaces.takeAt(idx);
        endRemoveRows();
    }
    if (!interfacesToAdd.isEmpty()) {
        beginInsertRows(QModelIndex(), static_cast<int>(m_interfaces.count()), static_cast<int>(m_interfaces.count()) + static_cast<int>(interfacesToAdd.count()) - 1);
        m_interfaces.append(interfacesToAdd);
        endInsertRows();
    }
    emit countChanged();
}

void InterfacesModel::rowsChanged(const QModelIndex &index, int first, int last)
{
    Q_UNUSED(index)
    Q_UNUSED(first)
    Q_UNUSED(last)

    syncInterfaces();
}

InterfacesSortModel::InterfacesSortModel(QObject *parent):
    QSortFilterProxyModel(parent)
{
}

InterfacesModel *InterfacesSortModel::interfacesModel() const
{
    return m_interfacesModel;
}

void InterfacesSortModel::setInterfacesModel(InterfacesModel *interfacesModel)
{
    if (m_interfacesModel != interfacesModel) {
        m_interfacesModel = interfacesModel;
        setSourceModel(interfacesModel);
        connect(interfacesModel, &InterfacesModel::countChanged, this, &InterfacesSortModel::countChanged);
        setSortRole(Things::RoleName);
        sort(0);
        emit interfacesModelChanged();
    }
}

bool InterfacesSortModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    QVariant leftName = sourceModel()->data(left, InterfacesModel::RoleName);
    QVariant rightName = sourceModel()->data(right, InterfacesModel::RoleName);

    if (leftName == "uncategorized") {
        return false;
    }
    if (rightName == "uncategorized") {
        return true;
    }
    return m_interfacesModel->shownInterfaces().indexOf(leftName.toString()) < m_interfacesModel->shownInterfaces().indexOf(rightName.toString());
}

QString InterfacesSortModel::get(int index) const
{
    return m_interfacesModel->get(mapToSource(this->index(index, 0)).row());
}
