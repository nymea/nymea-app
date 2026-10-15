// SPDX-License-Identifier: GPL-3.0-or-later

#include "rfidtags.h"

#include "rfidtaginfo.h"

#include <algorithm>

namespace {
QString sortKey(RfidTagInfo *tagInfo)
{
    const QString display = tagInfo->displayName().trimmed();
    if (!display.isEmpty())
        return display;

    const QString username = tagInfo->username().trimmed();
    if (!username.isEmpty())
        return username;

    return tagInfo->tagHash();
}

bool tagLess(RfidTagInfo *lhs, RfidTagInfo *rhs)
{
    const int compareResult = QString::localeAwareCompare(sortKey(lhs), sortKey(rhs));
    if (compareResult != 0)
        return compareResult < 0;

    return lhs->inventoryItemId().toString() < rhs->inventoryItemId().toString();
}
}

RfidTags::RfidTags(QObject *parent)
    : QAbstractListModel(parent)
{
}

int RfidTags::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_tags.count();
}

QVariant RfidTags::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_tags.count())
        return QVariant();

    RfidTagInfo *tagInfo = m_tags.at(index.row());
    switch (role) {
    case RoleInventoryItemId:
        return tagInfo->inventoryItemId();
    case RoleUsername:
        return tagInfo->username();
    case RoleDisplayName:
        return tagInfo->displayName();
    case RoleEnabled:
        return tagInfo->enabled();
    case RoleAllowStopCharging:
        return tagInfo->allowStopCharging();
    case RoleTagHash:
        return tagInfo->tagHash();
    case RoleProfile:
        return tagInfo->profile();
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> RfidTags::roleNames() const
{
    return {
        {RoleInventoryItemId, "inventoryItemId"},
        {RoleUsername, "username"},
        {RoleDisplayName, "displayName"},
        {RoleEnabled, "enabled"},
        {RoleAllowStopCharging, "allowStopCharging"},
        {RoleTagHash, "tagHash"},
        {RoleProfile, "profile"}
    };
}

void RfidTags::setTags(const QVariantList &tags)
{
    beginResetModel();
    qDeleteAll(m_tags);
    m_tags.clear();

    for (const QVariant &tagVariant : tags) {
        RfidTagInfo *tagInfo = new RfidTagInfo(this);
        tagInfo->updateFromVariantMap(tagVariant.toMap());
        connectTag(tagInfo);
        m_tags.append(tagInfo);
    }

    std::sort(m_tags.begin(), m_tags.end(), tagLess);
    endResetModel();
    emit countChanged();
}

void RfidTags::upsertTag(const QVariantMap &tagMap)
{
    const QUuid inventoryItemId = tagMap.value("inventoryItemId").toUuid();
    if (inventoryItemId.isNull())
        return;

    for (int i = 0; i < m_tags.count(); ++i) {
        if (m_tags.at(i)->inventoryItemId() != inventoryItemId)
            continue;

        m_tags.at(i)->updateFromVariantMap(tagMap);
        beginResetModel();
        std::sort(m_tags.begin(), m_tags.end(), tagLess);
        endResetModel();
        return;
    }

    RfidTagInfo *tagInfo = new RfidTagInfo(this);
    tagInfo->updateFromVariantMap(tagMap);
    connectTag(tagInfo);

    const auto insertIt = std::lower_bound(m_tags.begin(), m_tags.end(), tagInfo, tagLess);
    const int insertIndex = std::distance(m_tags.begin(), insertIt);

    beginInsertRows(QModelIndex(), insertIndex, insertIndex);
    m_tags.insert(insertIndex, tagInfo);
    endInsertRows();
    emit countChanged();
}

void RfidTags::removeTag(const QUuid &inventoryItemId)
{
    for (int i = 0; i < m_tags.count(); ++i) {
        if (m_tags.at(i)->inventoryItemId() != inventoryItemId)
            continue;

        beginRemoveRows(QModelIndex(), i, i);
        m_tags.takeAt(i)->deleteLater();
        endRemoveRows();
        emit countChanged();
        return;
    }
}

RfidTagInfo *RfidTags::get(int index) const
{
    if (index < 0 || index >= m_tags.count())
        return nullptr;

    return m_tags.at(index);
}

RfidTagInfo *RfidTags::getTagInfo(const QUuid &inventoryItemId) const
{
    for (RfidTagInfo *tagInfo : m_tags) {
        if (tagInfo->inventoryItemId() == inventoryItemId)
            return tagInfo;
    }

    return nullptr;
}

void RfidTags::connectTag(RfidTagInfo *tagInfo)
{
    auto emitChanges = [this, tagInfo](const QVector<int> &roles) {
        const int idx = m_tags.indexOf(tagInfo);
        if (idx < 0)
            return;

        emit dataChanged(index(idx), index(idx), roles);
    };

    connect(tagInfo, &RfidTagInfo::usernameChanged, this, [emitChanges]() { emitChanges({RoleUsername}); });
    connect(tagInfo, &RfidTagInfo::displayNameChanged, this, [emitChanges]() { emitChanges({RoleDisplayName}); });
    connect(tagInfo, &RfidTagInfo::enabledChanged, this, [emitChanges]() { emitChanges({RoleEnabled}); });
    connect(tagInfo, &RfidTagInfo::allowStopChargingChanged, this, [emitChanges]() { emitChanges({RoleAllowStopCharging}); });
    connect(tagInfo, &RfidTagInfo::tagHashChanged, this, [emitChanges]() { emitChanges({RoleTagHash}); });
    connect(tagInfo, &RfidTagInfo::profileChanged, this, [emitChanges]() { emitChanges({RoleProfile}); });
}
