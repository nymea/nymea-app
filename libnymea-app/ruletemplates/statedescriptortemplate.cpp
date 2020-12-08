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
