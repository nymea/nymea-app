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

#include "tag.h"

#include <QDebug>

#include "logging.h"
NYMEA_LOGGING_CATEGORY(dcTags, "Tags")

Tag::Tag(const QString &tagId, const QString &value, QObject *parent):
    QObject(parent),
    m_tagId(tagId),
    m_value(value)
{

}

QUuid Tag::thingId() const
{
    return m_thingId;
}

void Tag::setThingId(const QUuid &thingId)
{
    m_thingId = thingId;
}

QUuid Tag::ruleId() const
{
    return m_ruleId;
}

void Tag::setRuleId(const QUuid &ruleId)
{
    m_ruleId = ruleId;
}

QString Tag::tagId() const
{
    return m_tagId;
}

QString Tag::value() const
{
    return m_value;
}

void Tag::setValue(const QString &value)
{
    if (m_value != value) {
        m_value = value;
        qDebug() << "tags value changed" << m_thingId.toString() << m_tagId << value;
        emit valueChanged();
    }
}

bool Tag::equals(Tag *other) const
{
    return m_tagId == other->tagId() && m_thingId == other->thingId() && m_ruleId == other->ruleId() && m_value == other->value();
}
