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

#include "actiontypes.h"

ActionTypes::ActionTypes(QObject *parent) :
    QAbstractListModel(parent)
{

}

QList<ActionType *> ActionTypes::actionTypes()
{
    return m_actionTypes;
}

ActionType *ActionTypes::get(int index) const
{
    return m_actionTypes.at(index);
}

ActionType *ActionTypes::getActionType(const QString &actionTypeId) const
{
    foreach (ActionType *actionType, m_actionTypes) {
        if (actionType->id() == actionTypeId) {
            return actionType;
        }
    }
    return 0;
}

int ActionTypes::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_actionTypes.count();
}

QVariant ActionTypes::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_actionTypes.count())
        return QVariant();

    ActionType *actionType = m_actionTypes.at(index.row());
    if (role == NameRole) {
        return actionType->name();
    } else if (role == IdRole) {
        return actionType->id();
    }
    return QVariant();
}

void ActionTypes::addActionType(ActionType *actionType)
{
    beginInsertRows(QModelIndex(), m_actionTypes.count(), m_actionTypes.count());
    //qDebug() << "ActionTypes: loaded actionType" << actionType->name();
    m_actionTypes.append(actionType);
    endInsertRows();
    emit countChanged();
}

ActionType *ActionTypes::findByName(const QString &name) const
{
    foreach (ActionType *at, m_actionTypes) {
        if (at->name() == name) {
            return at;
        }
    }
    return nullptr;
}

void ActionTypes::clearModel()
{
    beginResetModel();
    m_actionTypes.clear();
    endResetModel();
    emit countChanged();
}

QHash<int, QByteArray> ActionTypes::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[IdRole] = "id";
    return roles;
}
