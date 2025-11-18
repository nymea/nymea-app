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

#include "statedescriptortemplate.h"

StateDescriptorTemplate::StateDescriptorTemplate(const QString &interfaceName, const QString &stateName, int selectionId, StateDescriptorTemplate::SelectionMode selectionMode, StateDescriptorTemplate::ValueOperator valueOperator, const QVariant &value, QObject *parent):
    QObject(parent),
    m_interfaceName(interfaceName),
    m_stateName(stateName),
    m_selectionId(selectionId),
    m_selectionMode(selectionMode),
    m_valueOperator(valueOperator),
    m_value(value)
{

}

QString StateDescriptorTemplate::interfaceName() const
{
    return m_interfaceName;
}

QString StateDescriptorTemplate::stateName() const
{
    return m_stateName;
}

int StateDescriptorTemplate::selectionId() const
{
    return m_selectionId;
}

StateDescriptorTemplate::SelectionMode StateDescriptorTemplate::selectionMode() const
{
    return m_selectionMode;
}

StateDescriptorTemplate::ValueOperator StateDescriptorTemplate::valueOperator() const
{
    return m_valueOperator;
}

QVariant StateDescriptorTemplate::value() const
{
    return m_value;
}
