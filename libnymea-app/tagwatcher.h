#ifndef TAGWATCHER_H
#define TAGWATCHER_H

#include <QObject>
#include <QUuid>

#include "types/tag.h"
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
