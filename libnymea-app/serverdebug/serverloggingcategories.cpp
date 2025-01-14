/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2024, nymea GmbH
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

#include "serverloggingcategories.h"

#include <QDebug>

ServerLoggingCategories::ServerLoggingCategories(QObject *parent)
    : QAbstractListModel{parent}
{}

int ServerLoggingCategories::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant ServerLoggingCategories::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleName:
        return m_list.at(index.row())->name();
    case RoleLevel:
        return m_list.at(index.row())->level();
    case RoleType:
        return m_list.at(index.row())->type();
    }
    return QVariant();
}

QHash<int, QByteArray> ServerLoggingCategories::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleName, "name");
    roles.insert(RoleLevel, "level");
    roles.insert(RoleType, "type");
    return roles;
}

void ServerLoggingCategories::createFromVariantList(const QVariantList &loggingCategories)
{
    beginResetModel();

    if (!m_list.isEmpty())
        qDeleteAll(m_list);

    foreach(const QVariant &categoryVariant, loggingCategories) {
        QVariantMap categoryMap = categoryVariant.toMap();

        // Make sure we don't add duplicated categories
        bool duplicated = false;
        foreach(ServerLoggingCategory *c, m_list) {
            if (c->name() == categoryMap.value("name").toString()) {
                qWarning() << "Duplicated server logging category" << categoryMap;
                duplicated = true;
            }
        }

        if (duplicated)
            continue;

        ServerLoggingCategory *category = new ServerLoggingCategory(categoryMap, this);

        connect(category, &ServerLoggingCategory::levelChanged, this, [this, category](ServerLoggingCategory::Level level) {
            Q_UNUSED(level)
            QModelIndex idx = index(m_list.indexOf(category), 0);
            emit dataChanged(idx, idx, {RoleLevel});
        });

        m_list.append(category);
    }

    endResetModel();
}

ServerLoggingCategory *ServerLoggingCategories::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }

    return m_list.at(index);
}
