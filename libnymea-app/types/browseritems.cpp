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
