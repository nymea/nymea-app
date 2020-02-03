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

#include "scripts.h"

#include "script.h"

Scripts::Scripts(QObject *parent) : QAbstractListModel(parent)
{

}

int Scripts::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant Scripts::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleId:
        return m_list.at(index.row())->id();
    case RoleName:
        return m_list.at(index.row())->name();
    }
    return QVariant();
}

QHash<int, QByteArray> Scripts::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleId, "id");
    roles.insert(RoleName, "name");
    return roles;

}

void Scripts::clear()
{
    beginResetModel();
    qDeleteAll(m_list);
    m_list.clear();
    endResetModel();
    emit countChanged();
}

void Scripts::addScript(Script *script)
{
    script->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(script);
    endInsertRows();
    emit countChanged();

    connect(script, &Script::nameChanged, this, [this, script](){
        int idx = m_list.indexOf(script);
        if (idx < 0) return;
        emit dataChanged(index(idx), index(idx), {RoleName});
    });
}

void Scripts::removeScript(const QUuid &id)
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->id() == id) {
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            emit countChanged();
            return;
        }
    }
}

Script* Scripts::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

Script *Scripts::getScript(const QUuid &scriptId)
{
    foreach (Script *script, m_list) {
        if (script->id() == scriptId) {
            return script;
        }
    }
    return nullptr;
}
