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
