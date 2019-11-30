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
    explicit TagsManager(JsonRpcClient *jsonClient, QObject *parent = nullptr);
    QString nameSpace() const override;

    void init();
    void clear();
    bool busy() const;

    Tags* tags() const;

    Q_INVOKABLE void tagDevice(const QString &deviceId, const QString &tagId, const QString &value);
    Q_INVOKABLE void untagDevice(const QString &deviceId, const QString &tagId);
    Q_INVOKABLE void tagRule(const QString &ruleId, const QString &tagId, const QString &value);
    Q_INVOKABLE void untagRule(const QString &ruleId, const QString &tagId);

signals:
    void busyChanged();

private slots:
    void handleTagsNotification(const QVariantMap &params);
    void getTagsReply(const QVariantMap &params);
    void addTagReply(const QVariantMap &params);
    void removeTagReply(const QVariantMap &params);

private:
    Tag *unpackTag(const QVariantMap &tagMap);

    JsonRpcClient *m_jsonClient = nullptr;

    Tags *m_tags = nullptr;
    bool m_busy = false;
};

#endif // TAGSMANAGER_H
