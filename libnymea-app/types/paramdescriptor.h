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

#ifndef PARAMDESCRIPTOR_H
#define PARAMDESCRIPTOR_H

#include "param.h"

class ParamDescriptor : public Param
{
    Q_OBJECT
    Q_PROPERTY(QString paramName READ paramName WRITE setParamName NOTIFY paramNameChanged)
    Q_PROPERTY(ValueOperator operatorType READ operatorType WRITE setOperatorType NOTIFY operatorTypeChanged)
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

    explicit ParamDescriptor(QObject *parent = nullptr);

    QString paramName() const;
    void setParamName(const QString &paramName);

    ValueOperator operatorType() const;
    void setOperatorType(ValueOperator operatorType);

    ParamDescriptor* clone() const;
    bool operator==(ParamDescriptor *other) const;

signals:
    void paramNameChanged();
    void operatorTypeChanged();

private:
    QString m_paramName;
    ValueOperator m_operator;
};

#endif // PARAMDESCRIPTOR_H
