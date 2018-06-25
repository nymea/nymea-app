/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of nymea:app                                       *
 *                                                                         *
 *  This library is free software; you can redistribute it and/or          *
 *  modify it under the terms of the GNU Lesser General Public             *
 *  License as published by the Free Software Foundation; either           *
 *  version 2.1 of the License, or (at your option) any later version.     *
 *                                                                         *
 *  This library is distributed in the hope that it will be useful,        *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU      *
 *  Lesser General Public License for more details.                        *
 *                                                                         *
 *  You should have received a copy of the GNU Lesser General Public       *
 *  License along with this library; If not, see                           *
 *  <http://www.gnu.org/licenses/>.                                        *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "states.h"

#include <QDebug>

States::States(QObject *parent) :
    QAbstractListModel(parent)
{
}

QList<State *> States::states()
{
    return m_states;
}

int States::count() const
{
    return m_states.count();
}

State *States::get(int index) const
{
    return m_states.at(index);
}

State *States::getState(const QUuid &stateTypeId) const
{
    foreach (State *state, m_states) {
        if (state->stateTypeId() == stateTypeId) {
            return state;
        }
    }
    return 0;
}

int States::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_states.count();
}

QVariant States::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_states.count())
        return QVariant();

    State *state = m_states.at(index.row());
    if (role == ValueRole) {
        return state->value();
    } else if (role == StateTypeIdRole) {
        return state->stateTypeId().toString();
    }
    return QVariant();
}

void States::addState(State *state)
{
    beginInsertRows(QModelIndex(), m_states.count(), m_states.count());
    //qDebug() << "States: loaded state" << state->stateTypeId();
    m_states.append(state);
    endInsertRows();
}

QHash<int, QByteArray> States::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[StateTypeIdRole] = "stateTypeId";
    roles[ValueRole] = "value";
    return roles;
}

