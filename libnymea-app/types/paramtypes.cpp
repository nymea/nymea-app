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

#include "paramtypes.h"

ParamTypes::ParamTypes(QObject *parent) :
    QAbstractListModel(parent)
{
}

QList<ParamType *> ParamTypes::paramTypes()
{
    return m_paramTypes;
}

ParamType *ParamTypes::get(int index) const
{
    if (index >= 0 && index < m_paramTypes.count()) {
        return m_paramTypes.at(index);
    }
    return nullptr;
}

ParamType *ParamTypes::getParamType(const QUuid &id) const
{
    foreach (ParamType *paramType, m_paramTypes) {
        if (paramType->id() == id) {
            return paramType;
        }
    }
    return nullptr;
}

ParamType *ParamTypes::findByName(const QString &name) const
{
    foreach (ParamType *paramType, m_paramTypes) {
        if (paramType->name() == name) {
            return paramType;
        }
    }
    return nullptr;
}

int ParamTypes::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_paramTypes.count();
}

QVariant ParamTypes::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_paramTypes.count())
        return QVariant();

    ParamType *paramType = m_paramTypes.at(index.row());
    if (role == NameRole) {
        return paramType->name();
    } else if (role == DisplayNameRole) {
        return paramType->displayName();
    } else if (role == IdRole) {
        return paramType->id();
    } else if (role == TypeRole) {
        return paramType->type();
    } else if (role == DefaultValueRole) {
        return paramType->defaultValue();
    } else if (role == MinValueRole) {
        return paramType->minValue();
    } else if (role == MaxValueRole) {
        return paramType->maxValue();
    } else if (role == InputTypeRole) {
        return paramType->inputType();
    } else if (role == AllowedValuesRole) {
        return paramType->allowedValues();
    } else if (role == ReadOnlyRole) {
        return paramType->readOnly();
    }
    return QVariant();
}

void ParamTypes::addParamType(ParamType *paramType)
{
    paramType->setParent(this);
    beginInsertRows(QModelIndex(), m_paramTypes.count(), m_paramTypes.count());
    //qDebug() << "ParamTypes: loaded paramType" << paramType->name();
    m_paramTypes.append(paramType);
    endInsertRows();
    emit countChanged();
}

void ParamTypes::clearModel()
{
    beginResetModel();
    m_paramTypes.clear();
    endResetModel();
    emit countChanged();
}

QHash<int, QByteArray> ParamTypes::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[NameRole] = "name";
    roles[DisplayNameRole] = "displayName";
    roles[TypeRole] = "type";
    roles[MinValueRole] = "minValue";
    roles[MaxValueRole] = "maxValue";
    roles[InputTypeRole] = "inputType";
    roles[AllowedValuesRole] = "allowedValues";
    roles[ReadOnlyRole] = "readOnly";
    return roles;
}
