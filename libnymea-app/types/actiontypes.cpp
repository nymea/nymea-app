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

ActionType *ActionTypes::getActionType(const QUuid &actionTypeId) const
{
    foreach (ActionType *actionType, m_actionTypes) {
        if (actionType->id() == actionTypeId) {
            return actionType;
        }
    }
    return nullptr;
}

int ActionTypes::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_actionTypes.count();
}

QVariant ActionTypes::data(const QModelIndex &index, int role) const
{
    ActionType *actionType = m_actionTypes.at(index.row());
    switch (role) {
    case RoleId:
        return actionType->id();
    case RoleName:
        return actionType->name();
    case RoleDisplayName:
        return actionType->displayName();
    }
    return QVariant();
}

void ActionTypes::addActionType(ActionType *actionType)
{
    actionType->setParent(this);
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
    roles.insert(RoleId, "id");
    roles.insert(RoleName, "name");
    roles.insert(RoleDisplayName, "displayName");
    return roles;
}
