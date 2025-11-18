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

#include "scripts.h"

#include "script.h"

Scripts::Scripts(QObject *parent) : QAbstractListModel(parent)
{

}

int Scripts::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant Scripts::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleId:
        return m_list.at(index.row())->id();
    case RoleName:
        return m_list.at(index.row())->name();
    }
    return QVariant();
}

QHash<int, QByteArray> Scripts::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleId, "id");
    roles.insert(RoleName, "name");
    return roles;

}

void Scripts::clear()
{
    beginResetModel();
    qDeleteAll(m_list);
    m_list.clear();
    endResetModel();
    emit countChanged();
}

void Scripts::addScript(Script *script)
{
    script->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(script);
    endInsertRows();
    emit countChanged();

    connect(script, &Script::nameChanged, this, [this, script](){
        int idx = m_list.indexOf(script);
        if (idx < 0) return;
        emit dataChanged(index(idx), index(idx), {RoleName});
    });
}

void Scripts::removeScript(const QUuid &id)
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->id() == id) {
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            emit countChanged();
            return;
        }
    }
}

Script* Scripts::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

Script *Scripts::getScript(const QUuid &scriptId)
{
    foreach (Script *script, m_list) {
        if (script->id() == scriptId) {
            return script;
        }
    }
    return nullptr;
}
