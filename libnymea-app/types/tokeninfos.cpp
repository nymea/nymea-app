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

#include "tokeninfos.h"
#include "tokeninfo.h"

TokenInfos::TokenInfos(QObject *parent) : QAbstractListModel(parent)
{

}

int TokenInfos::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return static_cast<int>(m_list.count());
}

QVariant TokenInfos::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleId:
        return m_list.at(index.row())->id();
    case RoleUsername:
        return m_list.at(index.row())->username();
    case RoleDeviceName:
        return m_list.at(index.row())->deviceName();
    case RoleCreationTime:
        return m_list.at(index.row())->creationTime();
    }
    return QVariant();
}

QHash<int, QByteArray> TokenInfos::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleId, "id");
    roles.insert(RoleUsername, "username");
    roles.insert(RoleDeviceName, "deviceName");
    roles.insert(RoleCreationTime, "creationTime");
    return roles;
}

void TokenInfos::addToken(TokenInfo *tokenInfo)
{
    tokenInfo->setParent(this);
    beginInsertRows(QModelIndex(), static_cast<int>(m_list.count()), static_cast<int>(m_list.count()));
    m_list.append(tokenInfo);
    endInsertRows();
    emit countChanged();
}

void TokenInfos::removeToken(const QUuid &tokenId)
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->id() == tokenId) {
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            emit countChanged();
            return;
        }
    }
}

TokenInfo *TokenInfos::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}
