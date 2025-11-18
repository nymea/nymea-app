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

#include "calendaritems.h"
#include "calendaritem.h"

CalendarItems::CalendarItems(QObject *parent) : QAbstractListModel(parent)
{

}

int CalendarItems::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant CalendarItems::data(const QModelIndex &index, int role) const
{
    Q_UNUSED(index)
    Q_UNUSED(role)
    return QVariant();
}

void CalendarItems::addCalendarItem(CalendarItem *calendarItem)
{
    calendarItem->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(calendarItem);
    endInsertRows();
    emit countChanged();
}

void CalendarItems::removeCalendarItem(int index)
{
    if (index < 0 || index > m_list.count()) {
        return;
    }
    beginRemoveRows(QModelIndex(), index, index);
    m_list.takeAt(index)->deleteLater();
    endRemoveRows();
    emit countChanged();
}

CalendarItem *CalendarItems::createNewCalendarItem() const
{
    return new CalendarItem();
}

CalendarItem *CalendarItems::get(int index) const
{
    if (index < 0 || index > m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

bool CalendarItems::operator==(CalendarItems *other) const
{
    if (rowCount() != other->rowCount()) {
        return false;
    }
    for (int i = 0; i < rowCount(); i++) {
        if (!get(i)->operator==(other->get(i))) {
            return false;
        }
    }
    return true;
}
