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
        if (t->thingId() != m_thingId && t->ruleId() != m_ruleId) {
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
