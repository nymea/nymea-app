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
