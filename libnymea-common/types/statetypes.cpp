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

#include "statetypes.h"

#include <QDebug>

StateTypes::StateTypes(QObject *parent) :
    QAbstractListModel(parent)
{
}

QList<StateType *> StateTypes::stateTypes()
{
    return m_stateTypes;
}

StateType *StateTypes::get(int index) const
{
    qDebug() << "returning" << m_stateTypes.at(index);
    return m_stateTypes.at(index);
}

StateType *StateTypes::getStateType(const QString &stateTypeId) const
{
    foreach (StateType *stateType, m_stateTypes) {
        if (stateType->id() == stateTypeId) {
            return stateType;
        }
    }
    return nullptr;
}

int StateTypes::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_stateTypes.count();
}

QVariant StateTypes::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_stateTypes.count())
        return QVariant();

    StateType *stateType = m_stateTypes.at(index.row());
    switch (role) {
    case RoleId:
        return stateType->id();
    case RoleName:
        return stateType->name();
    case RoleDisplayName:
        return stateType->displayName();
    case RoleType:
        return stateType->type();
    case RoleDefaultValue:
        return stateType->defaultValue();
    case RoleUnitString:
        return stateType->unitString();
    case RoleUnit:
        return stateType->unit();
    }
    return QVariant();
}

void StateTypes::addStateType(StateType *stateType)
{
    stateType->setParent(this);
    beginInsertRows(QModelIndex(), m_stateTypes.count(), m_stateTypes.count());
    m_stateTypes.append(stateType);
    endInsertRows();
    emit countChanged();
}

StateType *StateTypes::findByName(const QString &name) const
{
    foreach (StateType *stateType, m_stateTypes) {
        if (stateType->name() == name) {
            return stateType;
        }
    }
    return nullptr;
}

void StateTypes::clearModel()
{
    beginResetModel();
    qDebug() << "StateTypes: delete all stateTypes";
    qDeleteAll(m_stateTypes);
    m_stateTypes.clear();
    endResetModel();
    emit countChanged();
}

QHash<int, QByteArray> StateTypes::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[RoleId] = "id";
    roles[RoleName] = "name";
    roles[RoleDisplayName] = "displayName";
    roles[RoleType] = "type";
    roles[RoleDefaultValue] = "defaultValue";
    roles[RoleUnitString] = "unitString";
    roles[RoleUnit] = "unit";
    return roles;
}

