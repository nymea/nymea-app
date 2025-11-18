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
    return nullptr;
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
    state->setParent(this);
    beginInsertRows(QModelIndex(), m_states.count(), m_states.count());
    //qDebug() << "States: loaded state" << state->stateTypeId();
    m_states.append(state);
    connect(state, &State::valueChanged, this, [state, this]() {
        int idx = m_states.indexOf(state);
        if (idx < 0) return;
        emit dataChanged(index(idx), index(idx), {ValueRole});
    });
    endInsertRows();
    emit countChanged();
}

QHash<int, QByteArray> States::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[StateTypeIdRole] = "stateTypeId";
    roles[ValueRole] = "value";
    return roles;
}

