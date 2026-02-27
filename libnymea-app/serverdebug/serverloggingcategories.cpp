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

#include "serverloggingcategories.h"

#include <QDebug>

ServerLoggingCategories::ServerLoggingCategories(QObject *parent)
    : QAbstractListModel{parent}
{}

int ServerLoggingCategories::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return static_cast<int>(m_list.count());
}

QVariant ServerLoggingCategories::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleName:
        return m_list.at(index.row())->name();
    case RoleLevel:
        return m_list.at(index.row())->level();
    case RoleType:
        return m_list.at(index.row())->type();
    }
    return QVariant();
}

QHash<int, QByteArray> ServerLoggingCategories::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleName, "name");
    roles.insert(RoleLevel, "level");
    roles.insert(RoleType, "type");
    return roles;
}

void ServerLoggingCategories::createFromVariantList(const QVariantList &loggingCategories)
{
    beginResetModel();

    if (!m_list.isEmpty()) {
        foreach (ServerLoggingCategory *category, m_list) {
            category->deleteLater();
        }
    }

    foreach(const QVariant &categoryVariant, loggingCategories) {
        QVariantMap categoryMap = categoryVariant.toMap();

        // Make sure we don't add duplicated categories
        bool duplicated = false;
        foreach(ServerLoggingCategory *c, m_list) {
            if (c->name() == categoryMap.value("name").toString()) {
                qWarning() << "Duplicated server logging category" << categoryMap;
                duplicated = true;
            }
        }

        if (duplicated)
            continue;

        ServerLoggingCategory *category = new ServerLoggingCategory(categoryMap, this);

        connect(category, &ServerLoggingCategory::levelChanged, this, [this, category](ServerLoggingCategory::Level level) {
            Q_UNUSED(level)
            QModelIndex idx = index(static_cast<int>(static_cast<int>(m_list.indexOf(category))), 0);
            emit dataChanged(idx, idx, {RoleLevel});
        });

        m_list.append(category);
    }

    endResetModel();
}

ServerLoggingCategory *ServerLoggingCategories::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }

    return m_list.at(index);
}
