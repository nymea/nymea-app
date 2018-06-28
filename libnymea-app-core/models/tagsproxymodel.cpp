#include "tagsproxymodel.h"
#include "engine.h"
#include "tagsmanager.h"
#include "types/tag.h"

TagsProxyModel::TagsProxyModel(QObject *parent) : QSortFilterProxyModel(parent)
{
    setSourceModel(Engine::instance()->tagsManager()->tags());
    connect(Engine::instance()->tagsManager()->tags(), &Tags::countChanged, this, &TagsProxyModel::countChanged, Qt::QueuedConnection);
    setSortRole(Tags::RoleValue);
    sort(0);
}

QString TagsProxyModel::filterTagId() const
{
    return m_filterTagId;
}

void TagsProxyModel::setFilterTagId(const QString &filterTagId)
{
    if (m_filterTagId != filterTagId) {
        m_filterTagId = filterTagId;
        emit filterTagIdChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString TagsProxyModel::filterDeviceId() const
{
    return m_filterDeviceId;
}

void TagsProxyModel::setFilterDeviceId(const QString &filterDeviceId)
{
    if (m_filterDeviceId != filterDeviceId) {
        m_filterDeviceId = filterDeviceId;
        emit filterDeviceIdChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString TagsProxyModel::filterRuleId() const
{
    return m_filterRuleId;
}

void TagsProxyModel::setFilterRuleId(const QString &filterRuleId)
{
    if (m_filterRuleId != filterRuleId) {
        m_filterRuleId = filterRuleId;
        emit filterRuleIdChanged();
        invalidateFilter();
        emit countChanged();
    }
}

Tag *TagsProxyModel::get(int index) const
{
    if (index < 0 || index > rowCount()) {
        return nullptr;
    }
    return Engine::instance()->tagsManager()->tags()->get(mapToSource(this->index(index, 0)).row());
}

Tag *TagsProxyModel::findTag(const QString &tagId) const
{
    for (int i = 0; i < rowCount(); i++) {
        Tag *tag = Engine::instance()->tagsManager()->tags()->get(mapToSource(index(i, 0)).row());
        if (tag->tagId() == tagId) {
            return tag;
        }
    }
    return nullptr;
}

bool TagsProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    Q_UNUSED(source_parent)
    Tag *tag = Engine::instance()->tagsManager()->tags()->get(source_row);
    if (!m_filterTagId.isEmpty()) {
        if (tag->tagId() != m_filterTagId) {
            return false;
        }
    }
    if (!m_filterDeviceId.isEmpty()) {
        if (tag->deviceId() != m_filterDeviceId) {
            return false;
        }
    }
    if (!m_filterRuleId.isEmpty()) {
        if (tag->ruleId() != m_filterRuleId) {
            return false;
        }
    }
    return true;
}

bool TagsProxyModel::lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const
{
    QString leftValue = Engine::instance()->tagsManager()->tags()->get(source_left.row())->value();
    QString rightValue = Engine::instance()->tagsManager()->tags()->get(source_right.row())->value();
    bool okLeft, okRight;;
    qlonglong leftAsNumber = leftValue.toLongLong(&okLeft);
    qlonglong rightAsNumber = rightValue.toLongLong(&okRight);
    if (okLeft && okRight) {
        return leftAsNumber < rightAsNumber;
    }
    return leftValue < rightValue;
}
