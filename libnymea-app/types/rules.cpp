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

#include "rules.h"
#include "rule.h"

#include <QDebug>

Rules::Rules(QObject *parent) : QAbstractListModel(parent)
{

}

void Rules::clear()
{
    beginResetModel();
    qDeleteAll(m_list);
    m_list.clear();
    endResetModel();
    emit countChanged();
}

int Rules::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return static_cast<int>(m_list.count());
}

QVariant Rules::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleName:
        return m_list.at(index.row())->name();
    case RoleId:
        return m_list.at(index.row())->id();
    case RoleEnabled:
        return m_list.at(index.row())->enabled();
    case RoleActive:
        return m_list.at(index.row())->active();
    case RoleExecutable:
        return m_list.at(index.row())->executable();
    }
    return QVariant();
}

QHash<int, QByteArray> Rules::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleName, "name");
    roles.insert(RoleId, "id");
    roles.insert(RoleEnabled, "enabled");
    roles.insert(RoleActive, "active");
    roles.insert(RoleExecutable, "executable");
    return roles;
}

void Rules::insert(Rule *rule)
{
    rule->setParent(this);
    beginInsertRows(QModelIndex(), static_cast<int>(m_list.count()), static_cast<int>(m_list.count()));
    m_list.append(rule);
    connect(rule, &Rule::enabledChanged, this, &Rules::ruleChanged);
    connect(rule, &Rule::activeChanged, this, &Rules::ruleChanged);
    connect(rule, &Rule::nameChanged, this, &Rules::ruleChanged);
    connect(rule, &Rule::executableChanged, this, &Rules::ruleChanged);
    endInsertRows();
    emit countChanged();
}

void Rules::remove(const QUuid &ruleId)
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->id() == ruleId) {
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            emit countChanged();
            return;
        }
    }
}

Rule *Rules::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

Rule *Rules::getRule(const QUuid &ruleId) const
{
    foreach (Rule *rule, m_list) {
        if (rule->id() == ruleId) {
            return rule;
        }
    }
    return nullptr;
}

void Rules::ruleChanged()
{
    Rule *rule = dynamic_cast<Rule*>(sender());
    if (!rule) {
        return;
    }
    int idx = static_cast<int>(m_list.indexOf(rule));
    if (idx < 0) {
        qDebug() << "Rule not found in list. Discarding changed event.";
        return;
    }
    QModelIndex modelIndex = index(idx);
    emit dataChanged(modelIndex, modelIndex, {RoleActive, RoleEnabled, RoleName, RoleExecutable});
}
