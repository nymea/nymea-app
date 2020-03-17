/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
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

bool StateEvaluator::containsDevice(const QUuid &deviceId) const
{
    if (m_stateDescriptor && m_stateDescriptor->deviceId() == deviceId) {
        return true;
    }
    for (int i = 0; i < m_childEvaluators->rowCount(); i++) {
        if (m_childEvaluators->get(i)->containsDevice(deviceId)) {
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
    ret->m_stateDescriptor->setDeviceId(this->m_stateDescriptor->deviceId());
    ret->m_stateDescriptor->setStateTypeId(this->m_stateDescriptor->stateTypeId());
    ret->m_stateDescriptor->setInterfaceName(this->m_stateDescriptor->interfaceName());
    ret->m_stateDescriptor->setInterfaceState(this->m_stateDescriptor->interfaceState());
    ret->m_stateDescriptor->setValueOperator(this->m_stateDescriptor->valueOperator());
    ret->m_stateDescriptor->setValue(this->m_stateDescriptor->value());
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
