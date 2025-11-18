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

#include "tagwatcher.h"
#include "types/tag.h"

TagWatcher::TagWatcher(QObject *parent) : QObject(parent)
{

}

Tags *TagWatcher::tags() const
{
    return m_tags;
}

void TagWatcher::setTags(Tags *tags)
{
    if (m_tags != tags) {
        if (m_tags) {
            disconnect(m_tags, &Tags::countChanged, this, &TagWatcher::update);
        }
        m_tags = tags;
        emit tagsChanged();

        if (m_tags) {
            connect(m_tags, &Tags::countChanged, this, &TagWatcher::update);
        }
        update();
    }
}

QUuid TagWatcher::thingId() const
{
    return m_thingId;
}

void TagWatcher::setThingId(const QUuid &thingId)
{
    if (m_thingId != thingId) {
        m_thingId = thingId;
        emit thingIdChanged();
        update();
    }
}

QUuid TagWatcher::ruleId() const
{
    return m_ruleId;
}

void TagWatcher::setRuleId(const QUuid &ruleId)
{
    if (m_ruleId != ruleId) {
        m_ruleId = ruleId;
        emit ruleIdChanged();
        update();
    }
}

QString TagWatcher::tagId() const
{
    return m_tagId;
}

void TagWatcher::setTagId(const QString &tagId)
{
    if (m_tagId != tagId) {
        m_tagId = tagId;
        emit tagIdChanged();
        update();
    }
}

Tag *TagWatcher::tag() const
{
    return m_tag;
}

void TagWatcher::update()
{
    qCDebug(dcTags) << "Updating tag for watcher:" << m_tags << m_thingId << m_tagId;
    if (!m_tags) {
        updateTag(nullptr);
        return;
    }

    if (m_thingId.isNull() && m_ruleId.isNull()) {
        updateTag(nullptr);
        return;
    }

    if (m_tagId.isEmpty()) {
        updateTag(nullptr);
        return;
    }

    Tag *tag = nullptr;
    for (int i = 0; i < m_tags->rowCount(); i++) {
        Tag *t = m_tags->get(i);
        if (t->tagId() != m_tagId) {
            continue;
        }
        if (!m_thingId.isNull() && t->thingId() != m_thingId) {
            continue;
        }
        if (!m_ruleId.isNull() && t->ruleId() != m_ruleId) {
            continue;
        }
        tag = t;
        break;
    }

    updateTag(tag);
}

void TagWatcher::updateTag(Tag *tag)
{
    if (m_tag != tag) {
        m_tag = tag;
        emit tagChanged();
    }
}
