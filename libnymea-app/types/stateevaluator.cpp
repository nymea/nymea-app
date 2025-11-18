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

#include "stateevaluator.h"
#include "stateevaluators.h"
#include "statedescriptor.h"

#include <QDebug>

StateEvaluator::StateEvaluator(QObject *parent) : QObject(parent)
{
    m_childEvaluators = new StateEvaluators(this);
    m_stateDescriptor = new StateDescriptor(this);
}

StateEvaluator::StateOperator StateEvaluator::stateOperator() const
{
    return m_operator;
}

void StateEvaluator::setStateOperator(StateEvaluator::StateOperator stateOperator)
{
    if (m_operator != stateOperator) {
        m_operator = stateOperator;
        emit stateOperatorChanged();
    }
}

StateEvaluators *StateEvaluator::childEvaluators() const
{
    return m_childEvaluators;
}

StateDescriptor *StateEvaluator::stateDescriptor() const
{
    return m_stateDescriptor;
}

void StateEvaluator::setStateDescriptor(StateDescriptor *stateDescriptor)
{
    if (m_stateDescriptor) {
        m_stateDescriptor->deleteLater();
    }
    stateDescriptor->setParent(this);
    m_stateDescriptor = stateDescriptor;
}

bool StateEvaluator::containsThing(const QUuid &thingId) const
{
    if (m_stateDescriptor && m_stateDescriptor->thingId() == thingId) {
        return true;
    }
    for (int i = 0; i < m_childEvaluators->rowCount(); i++) {
        if (m_childEvaluators->get(i)->containsThing(thingId)) {
            return true;
        }
    }
    return false;
}

StateEvaluator* StateEvaluator::addChildEvaluator()
{
    StateEvaluator* stateEvaluator = new StateEvaluator(m_childEvaluators);
    m_childEvaluators->addStateEvaluator(stateEvaluator);
    return stateEvaluator;
}

StateEvaluator *StateEvaluator::clone() const
{
    StateEvaluator *ret = new StateEvaluator();
    ret->m_operator = this->m_operator;
    delete ret->m_stateDescriptor; // Delete existing empty one and replace it with a clone of the
    ret->m_stateDescriptor = this->m_stateDescriptor->clone();
    for (int i = 0; i < this->m_childEvaluators->rowCount(); i++) {
        ret->m_childEvaluators->addStateEvaluator(this->m_childEvaluators->get(i)->clone());
    }
    return ret;
}

#define COMPARE(a, b) if (a != b) { qDebug() << a << "!=" << b; return false; }
#define COMPARE_PTR(a, b) if (!a->operator==(b)) { qDebug() << a << "!=" << b; return false; }
bool StateEvaluator::operator==(StateEvaluator *other) const
{
    COMPARE(m_operator, other->stateOperator());
    COMPARE_PTR(m_stateDescriptor, other->stateDescriptor());
    COMPARE_PTR(m_childEvaluators, other->childEvaluators());
    return true;
}
