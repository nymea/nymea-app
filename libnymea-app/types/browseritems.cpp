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

#include "browseritems.h"
#include "browseritem.h"

#include <QDebug>

BrowserItems::BrowserItems(const QUuid &thingId, const QString &itemId, QObject *parent):
    QAbstractListModel (parent),
    m_thingId(thingId),
    m_itemId(itemId)
{

}

BrowserItems::~BrowserItems()
{
    qDebug() << "Deleting BrowserItems";
}

QUuid BrowserItems::thingId() const
{
    return m_thingId;
}

QString BrowserItems::itemId() const
{
    return m_itemId;
}

bool BrowserItems::busy() const
{
    return m_busy;
}

int BrowserItems::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_list.count();
}

QVariant BrowserItems::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleId:
        return m_list.at(index.row())->id();
    case RoleDisplayName:
        return m_list.at(index.row())->displayName();
    case RoleDescription:
        return m_list.at(index.row())->description();
    case RoleIcon:
        return m_list.at(index.row())->icon();
    case RoleThumbnail:
        return m_list.at(index.row())->thumbnail();
    case RoleExecutable:
        return m_list.at(index.row())->executable();
    case RoleBrowsable:
        return m_list.at(index.row())->browsable();
    case RoleActionTypeIds:
        return m_list.at(index.row())->actionTypeIds();
    case RoleDisabled:
        return m_list.at(index.row())->disabled();

    case RoleMediaIcon:
        return m_list.at(index.row())->mediaIcon();
    }
    return QVariant();
}

QHash<int, QByteArray> BrowserItems::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleId, "id");
    roles.insert(RoleDisplayName, "displayName");
    roles.insert(RoleDescription, "description");
    roles.insert(RoleIcon, "icon");
    roles.insert(RoleThumbnail, "thumbnail");
    roles.insert(RoleExecutable, "executable");
    roles.insert(RoleBrowsable, "browsable");
    roles.insert(RoleDisabled, "disabled");
    roles.insert(RoleActionTypeIds, "actionTypeIds");

    roles.insert(RoleMediaIcon, "mediaIcon");
    return roles;
}

void BrowserItems::addBrowserItem(BrowserItem *browserItem)
{
    browserItem->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(browserItem);
    endInsertRows();
    emit countChanged();
}

void BrowserItems::removeItem(BrowserItem *browserItem)
{
    int idx = m_list.indexOf(browserItem);
    if (idx < 0) {
        return;
    }
    beginRemoveRows(QModelIndex(), idx, idx);
    m_list.takeAt(idx)->deleteLater();
    endRemoveRows();
}

QList<BrowserItem *> BrowserItems::list() const
{
    return m_list;
}

void BrowserItems::setBusy(bool busy)
{
    if (m_busy != busy) {
        m_busy = busy;
        emit busyChanged();
    }
}

BrowserItem *BrowserItems::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

BrowserItem *BrowserItems::getBrowserItem(const QString &itemId)
{
    foreach (BrowserItem *item, m_list) {
        if (item->id() == itemId) {
            return item;
        }
    }
    return nullptr;
}
