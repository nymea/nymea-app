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

#include "statetypesproxy.h"

StateTypesProxy::StateTypesProxy(QObject *parent) : QSortFilterProxyModel(parent)
{

}

StateTypes *StateTypesProxy::stateTypes() const
{
    return m_stateTypes;
}

void StateTypesProxy::setStateTypes(StateTypes *stateTypes)
{
    if (m_stateTypes != stateTypes) {
        m_stateTypes = stateTypes;
        setSourceModel(stateTypes);
        emit countChanged();
    }
}

bool StateTypesProxy::digitalInputs() const
{
    return m_digitalInputs;
}

void StateTypesProxy::setDigitalInputs(bool digitalInputs)
{
    if (m_digitalInputs != digitalInputs) {
        m_digitalInputs = digitalInputs;
        emit digitalInputsChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool StateTypesProxy::digitalOutputs() const
{
    return m_digitalOutputs;
}

void StateTypesProxy::setDigitalOutputs(bool digitalOutputs)
{
    if (m_digitalOutputs != digitalOutputs) {
        m_digitalOutputs = digitalOutputs;
        emit digitalOutputsChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool StateTypesProxy::analogInputs() const
{
    return m_analogInputs;
}

void StateTypesProxy::setAnalogInputs(bool analogInputs)
{
    if (m_analogInputs != analogInputs) {
        m_analogInputs = analogInputs;
        emit analogInputsChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool StateTypesProxy::analogOutputs() const
{
    return m_analogOutputs;
}

void StateTypesProxy::setAnalogOutputs(bool analogOutputs)
{
    if (m_analogOutputs != analogOutputs) {
        m_analogOutputs = analogOutputs;
        emit analogOutputsChanged();
        invalidateFilter();
        emit countChanged();
    }
}

StateType *StateTypesProxy::get(int index) const
{
    return m_stateTypes->get(mapToSource(this->index(index, 0)).row());
}

bool StateTypesProxy::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    Q_UNUSED(source_parent)

    if (!m_digitalInputs && !m_digitalOutputs && !m_analogInputs && !m_analogOutputs) {
        // filtering disabled
        return true;
    }

    StateType* stateType = m_stateTypes->get(source_row);
    switch (stateType->ioType()) {
    case Types::IOTypeNone:
        return false;
    case Types::IOTypeDigitalInput:
        return m_digitalInputs;
    case Types::IOTypeDigitalOutput:
        return m_digitalOutputs;
    case Types::IOTypeAnalogInput:
        return m_analogInputs;
    case Types::IOTypeAnalogOutput:
        return m_analogOutputs;
    }
    return false;
}
