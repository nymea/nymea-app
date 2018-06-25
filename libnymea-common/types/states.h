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

#ifndef STATES_H
#define STATES_H

#include <QObject>
#include <QAbstractListModel>

#include "state.h"

class States : public QAbstractListModel
{
    Q_OBJECT
public:
    enum StateRole {
        ValueRole = Qt::DisplayRole,
        StateTypeIdRole
    };

    explicit States(QObject *parent = 0);

    QList<State *> states();

    Q_INVOKABLE int count() const;
    Q_INVOKABLE State *get(int index) const;
    Q_INVOKABLE State *getState(const QUuid &stateTypeId) const;

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

    void addState(State *state);

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    QList<State *> m_states;
};

#endif // STATES_H
