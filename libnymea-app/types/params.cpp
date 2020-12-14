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
