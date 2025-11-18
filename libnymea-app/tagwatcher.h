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

#ifndef TAGWATCHER_H
#define TAGWATCHER_H

#include <QObject>
#include <QUuid>

#include "types/tags.h"

class TagWatcher : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Tags* tags READ tags WRITE setTags NOTIFY tagsChanged)
    Q_PROPERTY(QUuid thingId READ thingId WRITE setThingId NOTIFY thingIdChanged)
    Q_PROPERTY(QUuid ruleId READ ruleId WRITE setRuleId NOTIFY ruleIdChanged)
    Q_PROPERTY(QString tagId READ tagId WRITE setTagId NOTIFY tagIdChanged)
    Q_PROPERTY(Tag* tag READ tag NOTIFY tagChanged)
public:
    explicit TagWatcher(QObject *parent = nullptr);

    Tags* tags() const;
    void setTags(Tags *tags);

    QUuid thingId() const;
    void setThingId(const QUuid &thingId);

    QUuid ruleId() const;
    void setRuleId(const QUuid &ruleId);

    QString tagId() const;
    void setTagId(const QString &tagId);

    Tag* tag() const;

signals:
    void tagsChanged();
    void tagIdChanged();
    void thingIdChanged();
    void ruleIdChanged();
    void tagChanged();

private slots:
    void update();
    void updateTag(Tag *tag);

private:
    Tags* m_tags = nullptr;
    QUuid m_thingId;
    QUuid m_ruleId;
    QString m_tagId;
    Tag *m_tag = nullptr;
};

#endif // TAGWATCHER_H
