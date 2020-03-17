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

#include "eventdescriptortemplate.h"

EventDescriptorTemplate::EventDescriptorTemplate(const QString &interfaceName, const QString &interfaceEvent, int selectionId, SelectionMode selectionMode, QObject *parent):
    QObject(parent),
    m_interfaceName(interfaceName),
    m_interfaceEvent(interfaceEvent),
    m_selectionId(selectionId),
    m_selectionMode(selectionMode),
    m_paramDescriptors(new ParamDescriptors(this))
{

}

QString EventDescriptorTemplate::interfaceName() const
{
    return m_interfaceName;
}

QString EventDescriptorTemplate::interfaceEvent() const
{
    return m_interfaceEvent;
}

int EventDescriptorTemplate::selectionId() const
{
    return m_selectionId;
}

EventDescriptorTemplate::SelectionMode EventDescriptorTemplate::selectionMode() const
{
    return m_selectionMode;
}

ParamDescriptors *EventDescriptorTemplate::paramDescriptors() const
{
    return m_paramDescriptors;
}

QStringList EventDescriptorTemplates::interfaces() const
{
    QStringList ret;
    for (int i = 0; i < m_list.count(); i++) {
        ret.append(m_list.at(i)->interfaceName());
    }
    ret.removeDuplicates();
    return ret;
}
