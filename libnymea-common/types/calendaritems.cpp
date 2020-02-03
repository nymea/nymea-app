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
