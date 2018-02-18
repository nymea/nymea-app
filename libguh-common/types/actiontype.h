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

#ifndef ACTIONTYPE_H
#define ACTIONTYPE_H

#include <QObject>
#include <QUuid>

#include "paramtypes.h"

class ActionType : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id CONSTANT)
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString displayName READ displayName CONSTANT)
    Q_PROPERTY(int index READ index CONSTANT)
    Q_PROPERTY(ParamTypes *paramTypes READ paramTypes NOTIFY paramTypesChanged)

public:
    explicit ActionType(QObject *parent = 0);

    QString id() const;
    void setId(const QString &id);

    QString name() const;
    void setName(const QString &name);

    QString displayName() const;
    void setDisplayName(const QString &displayName);

    int index() const;
    void setIndex(const int &index);

    ParamTypes *paramTypes() const;
    void setParamTypes(ParamTypes *paramTypes);

private:
    QString m_id;
    QString m_name;
    QString m_displayName;
    int m_index;
    ParamTypes *m_paramTypes;

signals:
    void paramTypesChanged();

};

#endif // ACTIONTYPE_H
