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

#ifndef PARAMDESCRIPTORS_H
#define PARAMDESCRIPTORS_H

#include <QAbstractListModel>

#include "paramdescriptor.h"

class ParamDescriptors : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum ValueOperator {
        ValueOperatorEquals,
        ValueOperatorNotEquals,
        ValueOperatorLess,
        ValueOperatorGreater,
        ValueOperatorLessOrEqual,
        ValueOperatorGreaterOrEqual
    };
    Q_ENUM(ValueOperator)

    enum Roles {
        RoleId,
        RoleValue,
        RoleOperator
    };
    Q_ENUM(Roles)

    explicit ParamDescriptors(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE ParamDescriptor* get(int index) const;

    ParamDescriptor* createNewParamDescriptor() const;
    void addParamDescriptor(ParamDescriptor* paramDescriptor);

    Q_INVOKABLE void setParamDescriptor(const QUuid &paramTypeId, const QVariant &value, ValueOperator operatorType);
    Q_INVOKABLE void setParamDescriptorByName(const QString &paramName, const QVariant &value, ValueOperator operatorType);
    Q_INVOKABLE void clear();

    Q_INVOKABLE ParamDescriptor *getParamDescriptor(const QUuid &paramTypeId) const;
    Q_INVOKABLE ParamDescriptor *getParamDescriptorByName(const QString &paramName) const;

    bool operator==(ParamDescriptors *other) const;

signals:
    void countChanged();

private:
    QList<ParamDescriptor*> m_list;
};

#endif // PARAMDESCRIPTORS_H
