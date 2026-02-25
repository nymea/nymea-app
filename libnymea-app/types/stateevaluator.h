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

#ifndef STATEEVALUATOR_H
#define STATEEVALUATOR_H

#include <QObject>

#include "stateevaluators.h"
#include "statedescriptor.h"

class StateEvaluator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(StateOperator stateOperator READ stateOperator WRITE setStateOperator NOTIFY stateOperatorChanged)
    Q_PROPERTY(StateEvaluators* childEvaluators READ childEvaluators CONSTANT)
    Q_PROPERTY(StateDescriptor* stateDescriptor READ stateDescriptor CONSTANT)

public:
    enum StateOperator {
        StateOperatorAnd,
        StateOperatorOr
    };
    Q_ENUM(StateOperator)
    explicit StateEvaluator(QObject *parent = nullptr);

    StateOperator stateOperator() const;
    void setStateOperator(StateOperator stateOperator);

    StateEvaluators* childEvaluators() const;

    StateDescriptor* stateDescriptor() const;
    void setStateDescriptor(StateDescriptor *stateDescriptor);

    bool containsThing(const QUuid &thingId) const;

    Q_INVOKABLE StateEvaluator* addChildEvaluator();

    StateEvaluator* clone() const;
    bool operator==(StateEvaluator *other) const;

signals:
    void stateOperatorChanged();

private:
    StateOperator m_operator = StateOperatorAnd;
    StateEvaluators *m_childEvaluators = nullptr;
    StateDescriptor *m_stateDescriptor = nullptr;

};

#endif // STATEEVALUATOR_H
