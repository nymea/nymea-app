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

#ifndef STATETYPES_H
#define STATETYPES_H

#include <QObject>
#include <QAbstractListModel>

#include "statetype.h"

class StateTypes : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Role {
        RoleId,
        RoleName,
        RoleDisplayName,
        RoleType,
        RoleDefaultValue,
        RoleUnit,
        RoleUnitString,
        RoleIOType,
    };

    StateTypes(QObject *parent = nullptr);

    QList<StateType *> stateTypes();

    Q_INVOKABLE StateType *get(int index) const;
    Q_INVOKABLE StateType *getStateType(const QUuid &stateTypeId) const;

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

    void addStateType(StateType *stateType);

    Q_INVOKABLE StateType *findByName(const QString &name) const;

    QList<StateType*> ioStateTypes(Types::IOType ioType) const;

    void clearModel();

protected:
    QHash<int, QByteArray> roleNames() const;

signals:
    void countChanged();

private:
    QList<StateType *> m_stateTypes;

};

#endif // STATETYPES_H
