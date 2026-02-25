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

#ifndef STATE_H
#define STATE_H

#include <QUuid>
#include <QObject>
#include <QVariant>

class State : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid thingId READ thingId CONSTANT)
    Q_PROPERTY(QUuid stateTypeId READ stateTypeId CONSTANT)
    Q_PROPERTY(QVariant value READ value NOTIFY valueChanged)
    Q_PROPERTY(QVariant minValue READ minValue NOTIFY minValueChanged)
    Q_PROPERTY(QVariant maxValue READ maxValue NOTIFY maxValueChanged)
    Q_PROPERTY(QVariantList possibleValues READ possibleValues NOTIFY possibleValuesChanged)

public:
    explicit State(const QUuid &thingId, const QUuid &stateTypeId, const QVariant &value, QObject *parent = nullptr);

    QUuid thingId() const;
    QUuid stateTypeId() const;

    QVariant value() const;
    void setValue(const QVariant &value);

    QVariant minValue() const;
    void setMinValue(const QVariant &minValue);

    QVariant maxValue() const;
    void setMaxValue(const QVariant &maxValue);

    QVariantList possibleValues() const;
    void setPossibleValues(const QVariantList &possibleValues);

private:
    QUuid m_thingId;
    QUuid m_stateTypeId;
    QVariant m_value;
    QVariant m_minValue;
    QVariant m_maxValue;
    QVariantList m_possibleValues;

signals:
    void valueChanged();
    void minValueChanged();
    void maxValueChanged();
    void possibleValuesChanged();
};

#endif // STATE_H
