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

#include "tagsmanager.h"
#include "types/tag.h"
#include "engine.h"

#include <QJsonDocument>
#include <QMetaEnum>

TagsManager::TagsManager(JsonRpcClient *jsonClient, QObject *parent):
    QObject(parent),
    m_jsonClient(jsonClient),
    m_tags(new Tags(this))
{
    jsonClient->registerNotificationHandler(this, "Tags", "handleTagsNotification");
}

void TagsManager::init()
{
    m_busy = true;
    emit busyChanged();
    m_tags->clear();
    m_jsonClient->sendCommand("Tags.GetTags", this, "getTagsResponse");
}

void TagsManager::clear()
{
    m_tags->clear();
}

bool TagsManager::busy() const
{
    return m_busy;
}

Tags *TagsManager::tags() const
{
    return m_tags;
}

int TagsManager::tagThing(const QString &thingId, const QString &tagId, const QString &value)
{
    QVariantMap params;
    QVariantMap tag;
    tag.insert("thingId", thingId);
    tag.insert("appId", "nymea:app");
    tag.insert("tagId", tagId);
    tag.insert("value", value);
    params.insert("tag", tag);
    return m_jsonClient->sendCommand("Tags.AddTag", params, this, "addTagResponse");
}

int TagsManager::untagThing(const QString &thingId, const QString &tagId)
{
    QVariantMap params;
    QVariantMap tag;
    tag.insert("thingId", thingId);
    tag.insert("appId", "nymea:app");
    tag.insert("tagId", tagId);
    params.insert("tag", tag);
    return m_jsonClient->sendCommand("Tags.RemoveTag", params, this, "removeTagResponse");
}

int TagsManager::tagRule(const QString &ruleId, const QString &tagId, const QString &value)
{
    QVariantMap params;
    QVariantMap tag;
    tag.insert("ruleId", ruleId);
    tag.insert("appId", "nymea:app");
    tag.insert("tagId", tagId);
    tag.insert("value", value);
    params.insert("tag", tag);
    return m_jsonClient->sendCommand("Tags.AddTag", params, this, "addTagResponse");
}

int TagsManager::untagRule(const QString &ruleId, const QString &tagId)
{
    QVariantMap params;
    QVariantMap tag;
    tag.insert("ruleId", ruleId);
    tag.insert("appId", "nymea:app");
    tag.insert("tagId", tagId);
    params.insert("tag", tag);
    return m_jsonClient->sendCommand("Tags.RemoveTag", params, this, "removeTagResponse");
}

void TagsManager::handleTagsNotification(const QVariantMap &params)
{
    qCDebug(dcTags()) << "Tags notification:" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson());

    QVariantMap tagMap = params.value("params").toMap().value("tag").toMap();
    if (tagMap.value("appId").toString() != "nymea:app") {
        return; // not for us
    }

    QString notification = params.value("notification").toString();
    if (notification == "Tags.TagAdded") {
        Tag *tag = unpackTag(tagMap);
        if (tag) {
            m_tags->addTag(tag);
        }

    } else if (notification == "Tags.TagRemoved") {
        for (int i = 0; i < m_tags->rowCount(); i++) {
            Tag* tag = m_tags->get(i);
            QUuid thingId = tagMap.value("thingId").toUuid();
            QUuid ruleId = tagMap.value("ruleId").toUuid();
            QString tagId = tagMap.value("tagId").toString();
            if (thingId == tag->thingId() && ruleId == tag->ruleId() && tagId == tag->tagId()) {
                m_tags->removeTag(tag);
                return;
            }
        }
    } else if (notification == "Tags.TagValueChanged") {
        for (int i = 0; i < m_tags->rowCount(); i++) {
            Tag* tag = m_tags->get(i);
            QUuid thingId = tagMap.value("thingId").toUuid();
            QUuid ruleId = tagMap.value("ruleId").toUuid();
            QString tagId = tagMap.value("tagId").toString();
            if (thingId == tag->thingId() && ruleId == tag->ruleId() && tagId == tag->tagId()) {
                tag->setValue(tagMap.value("value").toString());
            }
        }
    }
}

void TagsManager::getTagsResponse(int /*commandId*/, const QVariantMap &params)
{
    QList<Tag*> tags;
    foreach (const QVariant &tagVariant, params.value("tags").toList()) {
        Tag *tag = unpackTag(tagVariant.toMap());
        if (tag) {
            tags.append(tag);
        }
    }
    m_tags->addTags(tags);

    m_busy = false;
    emit busyChanged();
}

void TagsManager::addTagResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcTags()) << "AddTag reply" << commandId << params;
    QMetaEnum metaEnum = QMetaEnum::fromType<TagsManager::TagError>();
    emit addTagReply(commandId, static_cast<TagsManager::TagError>(metaEnum.keyToValue(params.value("params").toMap().value("error").toByteArray())));
}

void TagsManager::removeTagResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcTags()) << "RemoveTag reply" << commandId << params;
    QMetaEnum metaEnum = QMetaEnum::fromType<TagsManager::TagError>();
    emit removeTagReply(commandId, static_cast<TagsManager::TagError>(metaEnum.keyToValue(params.value("params").toMap().value("error").toByteArray())));
}

Tag* TagsManager::unpackTag(const QVariantMap &tagMap)
{
    QUuid thingId = tagMap.value("thingId").toUuid();
    QUuid ruleId = tagMap.value("ruleId").toUuid();
    QString tagId = tagMap.value("tagId").toString();
    QString value = tagMap.value("value").toString();
    Tag *tag = nullptr;
    if (!thingId.isNull()) {
        tag = new Tag(tagId, value);
        tag->setThingId(thingId);
    } else if (!ruleId.isNull()) {
        tag = new Tag(tagId, value);
        tag->setRuleId(ruleId);
    } else {
        qCWarning(dcTags()) << "Invalid tag. Neither thingId nor ruleId are set. Skipping...";
        tag->deleteLater();
        return nullptr;
    }
//    qDebug() << "adding tag" << tag->tagId() << tag->value();
    return tag;
}
