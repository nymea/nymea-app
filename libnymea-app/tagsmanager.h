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

#ifndef TAGSMANAGER_H
#define TAGSMANAGER_H

#include "jsonrpc/jsonhandler.h"
#include "jsonrpc/jsonrpcclient.h"

#include "types/tags.h"

class TagsManager : public JsonHandler
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
    QString nameSpace() const override;

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
    bool m_busy = false;
};

#endif // TAGSMANAGER_H
