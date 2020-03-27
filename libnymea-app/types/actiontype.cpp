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

#include "actiontype.h"

ActionType::ActionType(QObject *parent) :
    QObject(parent)
{
}

QUuid ActionType::id() const
{
    return m_id;
}

void ActionType::setId(const QUuid &id)
{
    m_id = id;
}

QString ActionType::name() const
{
    return m_name;
}

void ActionType::setName(const QString &name)
{
    m_name = name;
}

QString ActionType::displayName() const
{
    return m_displayName;
}

void ActionType::setDisplayName(const QString &displayName)
{
    m_displayName = displayName;
}

int ActionType::index() const
{
    return m_index;
}

void ActionType::setIndex(const int &index)
{
    m_index = index;
}

ParamTypes *ActionType::paramTypes() const
{
    return m_paramTypes;
}

void ActionType::setParamTypes(ParamTypes *paramTypes)
{
    if (m_paramTypes && m_paramTypes->parent() == this) {
        m_paramTypes->deleteLater();
    }
    m_paramTypes = paramTypes;
    m_paramTypes->setParent(this);
    emit paramTypesChanged();
}
