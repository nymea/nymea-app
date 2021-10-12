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
    if (index < 0 || index >= m_stateTypes.count()) {
        return nullptr;
    }
    return m_stateTypes.at(index);
}

StateType *StateTypes::getStateType(const QUuid &stateTypeId) const
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
    case RoleUnit:
        return stateType->unit();
    case RoleIOType:
        return stateType->ioType();
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

QList<StateType *> StateTypes::ioStateTypes(Types::IOType ioType) const
{
    QList<StateType*> ret;
    foreach (StateType* stateType, m_stateTypes) {
        if (stateType->ioType() == ioType) {
            ret.append(stateType);
        }
    }
    return ret;
}

void StateTypes::clearModel()
{
    beginResetModel();
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
    roles[RoleIOType] = "ioType";
    return roles;
}

