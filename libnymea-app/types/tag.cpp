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
