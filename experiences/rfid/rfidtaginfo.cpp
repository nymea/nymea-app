// SPDX-License-Identifier: GPL-3.0-or-later

#include "rfidtaginfo.h"

RfidTagInfo::RfidTagInfo(QObject *parent)
    : QObject(parent)
{
}

QUuid RfidTagInfo::inventoryItemId() const
{
    return m_inventoryItemId;
}

void RfidTagInfo::setInventoryItemId(const QUuid &inventoryItemId)
{
    if (m_inventoryItemId == inventoryItemId)
        return;

    m_inventoryItemId = inventoryItemId;
    emit inventoryItemIdChanged();
}

QString RfidTagInfo::username() const
{
    return m_username;
}

void RfidTagInfo::setUsername(const QString &username)
{
    if (m_username == username)
        return;

    m_username = username;
    emit usernameChanged();
}

QString RfidTagInfo::displayName() const
{
    return m_displayName;
}

void RfidTagInfo::setDisplayName(const QString &displayName)
{
    if (m_displayName == displayName)
        return;

    m_displayName = displayName;
    emit displayNameChanged();
}

bool RfidTagInfo::enabled() const
{
    return m_enabled;
}

void RfidTagInfo::setEnabled(bool enabled)
{
    if (m_enabled == enabled)
        return;

    m_enabled = enabled;
    emit enabledChanged();
}

bool RfidTagInfo::allowStopCharging() const
{
    return m_allowStopCharging;
}

void RfidTagInfo::setAllowStopCharging(bool allowStopCharging)
{
    if (m_allowStopCharging == allowStopCharging)
        return;

    m_allowStopCharging = allowStopCharging;
    emit allowStopChargingChanged();
}

QString RfidTagInfo::tagHash() const
{
    return m_tagHash;
}

void RfidTagInfo::setTagHash(const QString &tagHash)
{
    if (m_tagHash == tagHash)
        return;

    m_tagHash = tagHash;
    emit tagHashChanged();
}

QVariantMap RfidTagInfo::profile() const
{
    return m_profile;
}

void RfidTagInfo::setProfile(const QVariantMap &profile)
{
    if (m_profile == profile)
        return;

    m_profile = profile;
    emit profileChanged();
}

void RfidTagInfo::updateFromVariantMap(const QVariantMap &tagMap)
{
    if (tagMap.contains("inventoryItemId"))
        setInventoryItemId(tagMap.value("inventoryItemId").toUuid());

    if (tagMap.contains("username"))
        setUsername(tagMap.value("username").toString());

    if (tagMap.contains("displayName"))
        setDisplayName(tagMap.value("displayName").toString());

    if (tagMap.contains("enabled"))
        setEnabled(tagMap.value("enabled").toBool());

    if (tagMap.contains("allowStopCharging"))
        setAllowStopCharging(tagMap.value("allowStopCharging").toBool());

    if (tagMap.contains("tagHash"))
        setTagHash(tagMap.value("tagHash").toString());

    if (tagMap.contains("profile"))
        setProfile(tagMap.value("profile").toMap());
}
