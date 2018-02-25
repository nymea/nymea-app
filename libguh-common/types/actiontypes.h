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

#ifndef ACTIONTYPES_H
#define ACTIONTYPES_H

#include <QObject>
#include <QAbstractListModel>

#include "actiontype.h"

class ActionTypes : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleId,
        RoleName,
        RoleDisplayName
    };

    ActionTypes(QObject *parent = 0);

    QList<ActionType *> actionTypes();

    Q_INVOKABLE ActionType *get(int index) const;
    Q_INVOKABLE ActionType *getActionType(const QString &actionTypeId) const;

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

    void addActionType(ActionType *actionType);

    Q_INVOKABLE ActionType *findByName(const QString &name) const;

    void clearModel();

signals:
    void countChanged();

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    QList<ActionType *> m_actionTypes;
};

#endif // ACTIONTYPES_H
