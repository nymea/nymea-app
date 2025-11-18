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

#ifndef STATETYPE_H
#define STATETYPE_H

#include <QVariant>
#include <QObject>
#include <QUuid>

#include "types.h"

class StateType : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid id READ id CONSTANT)
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString displayName READ displayName CONSTANT)
    Q_PROPERTY(QString type READ type CONSTANT)
    Q_PROPERTY(int index READ index CONSTANT)
    Q_PROPERTY(QVariant defaultValue READ defaultValue CONSTANT)
    Q_PROPERTY(QVariantList allowedValues READ possibleValues CONSTANT) // Deprecated
    Q_PROPERTY(QVariantList possibleValues READ possibleValues CONSTANT)
    Q_PROPERTY(QStringList possibleValuesDisplayNames READ possibleValuesDisplayNames CONSTANT)
    Q_PROPERTY(Types::Unit unit READ unit CONSTANT)
    Q_PROPERTY(Types::IOType ioType READ ioType CONSTANT)
    Q_PROPERTY(QVariant minValue READ minValue CONSTANT)
    Q_PROPERTY(QVariant maxValue READ maxValue CONSTANT)

public:
    StateType(QObject *parent = nullptr);

    QUuid id() const;
    void setId(const QUuid &id);

    QString name() const;
    void setName(const QString &name);

    QString displayName() const;
    void setDisplayName(const QString &displayName);

    QString type() const;
    void setType(const QString &type);
    void setType(QVariant::Type type);

    int index() const;
    void setIndex(const int &index);

    QVariant defaultValue() const;
    void setDefaultValue(const QVariant &defaultValue);

    QVariantList possibleValues() const;
    QStringList possibleValuesDisplayNames() const;
    void setPossibleValues(const QVariantList &values, const QStringList &displayNames);
    Q_INVOKABLE QString localizedValue(const QVariant &value) const;

    Types::Unit unit() const;
    void setUnit(const Types::Unit &unit);

    Types::IOType ioType() const;
    void setIOType(Types::IOType ioType);

    QVariant minValue() const;
    void setMinValue(const QVariant &minValue);

    QVariant maxValue() const;
    void setMaxValue(const QVariant &maxValue);

private:
    QUuid m_id;
    QString m_name;
    QString m_displayName;
    QString m_type;
    int m_index;
    QVariant m_defaultValue;
    QVariantList m_possibleValues;
    QStringList m_possibleValuesDisplayNames;
    Types::Unit m_unit = Types::UnitNone;
    Types::IOType m_ioType = Types::IOTypeNone;
    QVariant m_minValue;
    QVariant m_maxValue;
};

#endif // STATETYPE_H
