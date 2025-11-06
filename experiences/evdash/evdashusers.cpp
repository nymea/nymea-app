// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "evdashusers.h"

#include <algorithm>

namespace {
inline bool localeLess(const QString &lhs, const QString &rhs)
{
    return QString::localeAwareCompare(lhs, rhs) < 0;
}
}

EvDashUsers::EvDashUsers(QObject *parent)
    : QAbstractListModel(parent)
{

}

EvDashUsers::EvDashUsers(const QStringList &data, QObject *parent)
    : QAbstractListModel(parent), m_data(data)
{

}

int EvDashUsers::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_data.size();
}

QVariant EvDashUsers::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_data.size())
        return QVariant();

    if (role == Qt::DisplayRole || role == NameRole)
        return m_data.at(index.row());

    return QVariant();
}

QHash<int, QByteArray> EvDashUsers::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    return roles;
}

void EvDashUsers::setUsers(const QStringList &users)
{
    QStringList sortedUsers = users;
    sortedUsers.removeDuplicates();
    std::sort(sortedUsers.begin(), sortedUsers.end(), localeLess);

    if (sortedUsers == m_data)
        return;

    beginResetModel();
    m_data = sortedUsers;
    endResetModel();
}

void EvDashUsers::addUser(const QString &user)
{
    if (user.isEmpty() || m_data.contains(user))
        return;

    const auto insertIt = std::lower_bound(m_data.begin(), m_data.end(), user, localeLess);
    const int insertIndex = std::distance(m_data.begin(), insertIt);

    beginInsertRows(QModelIndex(), insertIndex, insertIndex);
    m_data.insert(insertIndex, user);
    endInsertRows();
}

void EvDashUsers::removeUser(const QString &user)
{
    int index = m_data.indexOf(user);
    if (index < 0)
        return;

    beginRemoveRows(QModelIndex(), index, index);
    m_data.removeAt(index);
    endRemoveRows();
}
