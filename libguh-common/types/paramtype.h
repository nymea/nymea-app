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

#ifndef PARAMTYPE_H
#define PARAMTYPE_H

#include <QVariant>
#include <QObject>
#include <QDebug>

#include "types.h"

class ParamType : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString type READ type CONSTANT)
    Q_PROPERTY(int index READ index CONSTANT)
    Q_PROPERTY(QVariant defaultValue READ defaultValue CONSTANT)
    Q_PROPERTY(QVariant minValue READ minValue CONSTANT)
    Q_PROPERTY(QVariant maxValue READ maxValue CONSTANT)
    Q_PROPERTY(Types::InputType inputType READ inputType CONSTANT)
    Q_PROPERTY(QString unitString READ unitString CONSTANT)
    Q_PROPERTY(QVariantList allowedValues READ allowedValues CONSTANT)
    Q_PROPERTY(bool readOnly READ readOnly CONSTANT)

public:
    ParamType(QObject *parent = 0);
    ParamType(const QString &name, const QVariant::Type type, const QVariant &defaultValue = QVariant(), QObject *parent = 0);

    QString name() const;
    void setName(const QString &name);

    QString type() const;
    void setType(const QString &type);

    int index() const;
    void setIndex(const int &index);

    QVariant defaultValue() const;
    void setDefaultValue(const QVariant &defaultValue);

    QVariant minValue() const;
    void setMinValue(const QVariant &minValue);

    QVariant maxValue() const;
    void setMaxValue(const QVariant &maxValue);

    Types::InputType inputType() const;
    void setInputType(const Types::InputType &inputType);

    Types::Unit unit() const;
    void setUnit(const Types::Unit &unit);

    QString unitString() const;
    void setUnitString(const QString &unitString);

    QList<QVariant> allowedValues() const;
    void setAllowedValues(const QList<QVariant> allowedValues);

    bool readOnly() const;
    void setReadOnly(const bool &readOnly);

private:
    QString m_name;
    QString m_type;
    int m_index;
    QVariant m_defaultValue;
    QVariant m_minValue;
    QVariant m_maxValue;
    Types::InputType m_inputType;
    Types::Unit m_unit;
    QString m_unitString;
    QVariantList m_allowedValues;
    bool m_readOnly;
};

#endif // PARAMTYPE_H
