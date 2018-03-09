/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of mea                                       *
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

#ifndef PARAMS_H
#define PARAMS_H

#include <QAbstractListModel>

#include "param.h"

class Params : public QAbstractListModel
{
    Q_OBJECT
public:
    enum RoleId {
        RoleId,
        RoleValue
    };

    explicit Params(QObject *parent = 0);

    QList<Param *> params();

    Q_INVOKABLE int count() const;
    Q_INVOKABLE Param *get(int index) const;
    Q_INVOKABLE Param *getParam(QString paramTypeId) const;

    Q_INVOKABLE int paramCount() const;

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

    Q_INVOKABLE void addParam(Param *param);

    void clearModel();

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    QList<Param *> m_params;

};

#endif // PARAMS_H
