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

#include "tagsmanager.h"
#include "types/tag.h"
#include "engine.h"

TagsManager::TagsManager(JsonRpcClient *jsonClient, QObject *parent):
    JsonHandler(parent),
    m_jsonClient(jsonClient),
    m_tags(new Tags(this))
{
    jsonClient->registerNotificationHandler(this, "handleTagsNotification");
}

QString TagsManager::nameSpace() const
{
    return "Tags";
}

void TagsManager::init()
{
    m_busy = true;
    emit busyChanged();
    m_tags->clear();
    m_jsonClient->sendCommand("Tags.GetTags", this, "getTagsReply");
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

int TagsManager::tagDevice(const QString &deviceId, const QString &tagId, const QString &value)
{
    QVariantMap params;
    QVariantMap tag;
    tag.insert("deviceId", deviceId);
    tag.insert("appId", "nymea:app");
    tag.insert("tagId", tagId);
    tag.insert("value", value);
    params.insert("tag", tag);
    return m_jsonClient->sendCommand("Tags.AddTag", params, this, "addTagReply");
}

int TagsManager::untagDevice(const QString &deviceId, const QString &tagId)
{
    QVariantMap params;
    QVariantMap tag;
    tag.insert("deviceId", deviceId);
    tag.insert("appId", "nymea:app");
    tag.insert("tagId", tagId);
    params.insert("tag", tag);
    return m_jsonClient->sendCommand("Tags.RemoveTag", params, this, "removeTagReply");
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
    return m_jsonClient->sendCommand("Tags.AddTag", params, this, "addTagReply");
}

int TagsManager::untagRule(const QString &ruleId, const QString &tagId)
{
    QVariantMap params;
    QVariantMap tag;
    tag.insert("ruleId", ruleId);
    tag.insert("appId", "nymea:app");
    tag.insert("tagId", tagId);
    params.insert("tag", tag);
    return m_jsonClient->sendCommand("Tags.RemoveTag", params, this, "removeTagReply");
}

void TagsManager::handleTagsNotification(const QVariantMap &params)
{
    qDebug() << "Have tags notification" << params;

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
            QUuid thingId;
            if (m_jsonClient->ensureServerVersion("5.0")) {
                thingId = tagMap.value("thingId").toUuid();
            } else {
                thingId = tagMap.value("deviceId").toUuid();
            }
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
            QUuid thingId;
            if (m_jsonClient->ensureServerVersion("5.0")) {
                thingId = tagMap.value("thingId").toUuid();
            } else {
                thingId = tagMap.value("deviceId").toUuid();
            }
            QUuid ruleId = tagMap.value("ruleId").toUuid();
            QString tagId = tagMap.value("tagId").toString();
            if (thingId == tag->thingId() && ruleId == tag->ruleId() && tagId == tag->tagId()) {
                tag->setValue(tagMap.value("value").toString());
            }
        }
    }
}

void TagsManager::getTagsReply(int /*commandId*/, const QVariantMap &params)
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

void TagsManager::addTagReply(int commandId, const QVariantMap &params)
{
    qDebug() << "AddTag reply" << commandId << params;
}

void TagsManager::removeTagReply(int commandId, const QVariantMap &params)
{
    qDebug() << "RemoveTag reply" << commandId << params;
}

Tag* TagsManager::unpackTag(const QVariantMap &tagMap)
{
    QString thingId;
    if (m_jsonClient->ensureServerVersion("5.0")) {
        thingId = tagMap.value("thingId").toString();
    } else {
        thingId = tagMap.value("deviceId").toString();
    }
    QString ruleId = tagMap.value("ruleId").toString();
    QString tagId = tagMap.value("tagId").toString();
    QString value = tagMap.value("value").toString();
    Tag *tag = nullptr;
    if (!thingId.isEmpty()) {
        tag = new Tag(tagId, value);
        tag->setThingId(thingId);
    } else if (!ruleId.isEmpty()) {
        tag = new Tag(tagId, value);
        tag->setRuleId(ruleId);
    } else {
        qWarning() << "Invalid tag. Neither deviceId nor ruleId are set. Skipping...";
        tag->deleteLater();
        return nullptr;
    }
//    qDebug() << "adding tag" << tag->tagId() << tag->value();
    return tag;
}
