/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of guh-control                                       *
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

#ifndef STATETYPES_H
#define STATETYPES_H

#include <QObject>
#include <QAbstractListModel>

#include "statetype.h"

class StateTypes : public QAbstractListModel
{
    Q_OBJECT

public:
    enum StateTypeRole {
        NameRole = Qt::DisplayRole,
        IdRole,
        TypeRole,
        DefaultValueRole,
        UnitRole,
        UnitStringRole
    };

    StateTypes(QObject *parent = 0);

    QList<StateType *> stateTypes();

    Q_INVOKABLE int count() const;
    Q_INVOKABLE StateType *get(int index) const;
    Q_INVOKABLE StateType *getStateType(const QUuid &stateTypeId) const;

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

    void addStateType(StateType *stateType);

    Q_INVOKABLE StateType *findByName(const QString &name) const;

    void clearModel();

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    QList<StateType *> m_stateTypes;

};

#endif // STATETYPES_H
