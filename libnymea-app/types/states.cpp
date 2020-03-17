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
}

QHash<int, QByteArray> States::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[StateTypeIdRole] = "stateTypeId";
    roles[ValueRole] = "value";
    return roles;
}

