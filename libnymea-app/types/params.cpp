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

#include "params.h"

#include <QDebug>
#include <QUuid>

Params::Params(QObject *parent) :
    QAbstractListModel(parent)
{
}

QList<Param *> Params::params()
{
    return m_params;
}

int Params::count() const
{
    return m_params.count();
}

Param *Params::get(int index) const
{
    if (index < 0 || index >= m_params.count()) {
        return nullptr;
    }
    return m_params.at(index);
}

Param *Params::getParam(const QUuid &paramTypeId) const
{
    foreach (Param *param, m_params) {
        if (param->paramTypeId() == paramTypeId) {
            return param;
        }
    }
    return nullptr;
}

int Params::paramCount() const
{
    return m_params.count();
}

int Params::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_params.count();
}

QVariant Params::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_params.count())
        return QVariant();

    Param *param = m_params.at(index.row());
    if (role == RoleId) {
        return param->paramTypeId();
    } else if (role == RoleValue) {
        return param->value();
    }
    return QVariant();
}

void Params::addParam(Param *param)
{
    param->setParent(this);
    beginInsertRows(QModelIndex(), m_params.count(), m_params.count());
    //qDebug() << "Params: loaded param" << param->name();
    m_params.append(param);
    endInsertRows();
    emit countChanged();
}

void Params::clearModel()
{
    beginResetModel();
    m_params.clear();
    endResetModel();
    emit countChanged();
}

QHash<int, QByteArray> Params::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[RoleId] = "id";
    roles[RoleValue] = "value";
    return roles;
}
