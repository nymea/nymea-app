/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of guh-control                                       *
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

#ifndef PARAMTYPES_H
#define PARAMTYPES_H

#include <QAbstractListModel>

#include "types/paramtype.h"

class ParamTypes : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum ParamTypeRole {
        NameRole = Qt::DisplayRole,
        TypeRole,
        DefaultValueRole,
        MinValueRole,
        MaxValueRole,
        InputTypeRole,
        UnitStringRole,
        AllowedValuesRole,
        ReadOnlyRole
    };

    explicit ParamTypes(QObject *parent = 0);

    QList<ParamType *> paramTypes();

    Q_INVOKABLE ParamType *get(int index) const;
    Q_INVOKABLE ParamType *getParamType(const QString &id) const;

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

    void addParamType(ParamType *paramType);

    void clearModel();

signals:
    void countChanged();

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    QList<ParamType *> m_paramTypes;
};

#endif // PARAMTYPES_H
