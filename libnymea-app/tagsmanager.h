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

#ifndef TAGSMANAGER_H
#define TAGSMANAGER_H

#include "jsonrpc/jsonrpcclient.h"

#include "types/tags.h"

class TagsManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Tags* tags READ tags CONSTANT)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)

public:
    enum TagError {
        TagErrorNoError,
        TagErrorThingNotFound,
        TagErrorRuleNotFound,
        TagErrorTagNotFound
    };
    Q_ENUM(TagError)

    explicit TagsManager(JsonRpcClient *jsonClient, QObject *parent = nullptr);

    void init();
    void clear();
    bool busy() const;

    Tags* tags() const;

    Q_INVOKABLE int tagThing(const QString &thingId, const QString &tagId, const QString &value);
    Q_INVOKABLE int untagThing(const QString &thingId, const QString &tagId);
    Q_INVOKABLE int tagRule(const QString &ruleId, const QString &tagId, const QString &value);
    Q_INVOKABLE int untagRule(const QString &ruleId, const QString &tagId);

signals:
    void busyChanged();
    void addTagReply(int commandId, TagError error);
    void removeTagReply(int commandId, TagError error);

private slots:
    void handleTagsNotification(const QVariantMap &params);
    void getTagsResponse(int commandId, const QVariantMap &params);
    void addTagResponse(int commandId, const QVariantMap &params);
    void removeTagResponse(int commandId, const QVariantMap &params);

private:
    Tag *unpackTag(const QVariantMap &tagMap);

    JsonRpcClient *m_jsonClient = nullptr;

    Tags *m_tags = nullptr;
    bool m_busy = true;
};

#endif // TAGSMANAGER_H
