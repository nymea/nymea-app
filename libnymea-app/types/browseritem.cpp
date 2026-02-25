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

#include "browseritem.h"

BrowserItem::BrowserItem(const QString &id, QObject *parent):
    QObject(parent),
    m_id(id)
{

}

QString BrowserItem::id() const
{
    return m_id;
}

QString BrowserItem::displayName() const
{
    return m_displayName;
}

void BrowserItem::setDisplayName(const QString &displayName)
{
    if (m_displayName != displayName) {
        m_displayName = displayName;
        emit displayNameChanged();
    }
}

QString BrowserItem::description() const
{
    return m_description;
}

void BrowserItem::setDescription(const QString &description)
{
    if (m_description != description) {
        m_description = description;
        emit descriptionChanged();
    }
}

QString BrowserItem::icon() const
{
    return m_icon;
}

void BrowserItem::setIcon(const QString &icon)
{
    if (m_icon != icon) {
        m_icon = icon;
        emit iconChanged();
    }
}

QString BrowserItem::thumbnail() const
{
    return m_thumbnail;
}

void BrowserItem::setThumbnail(const QString &thumbnail)
{
    if (m_thumbnail != thumbnail) {
        m_thumbnail = thumbnail;
        emit thumbnailChanged();
    }
}

bool BrowserItem::executable() const
{
    return m_executable;
}

void BrowserItem::setExecutable(bool executable)
{
    if (m_executable != executable) {
        m_executable = executable;
        emit executableChanged();
    }
}

bool BrowserItem::browsable() const
{
    return m_browsable;
}

void BrowserItem::setBrowsable(bool browsable)
{
    if (m_browsable != browsable) {
        m_browsable = browsable;
        emit browsableChanged();
    }
}

bool BrowserItem::disabled() const
{
    return m_disabled;
}

void BrowserItem::setDisabled(bool disabled)
{
    if (m_disabled != disabled) {
        m_disabled = disabled;
        emit disabledChanged();
    }
}

QStringList BrowserItem::actionTypeIds() const
{
    return m_actionTypeIds;
}

void BrowserItem::setActionTypeIds(const QStringList &actionTypeIds)
{
    if (m_actionTypeIds != actionTypeIds) {
        m_actionTypeIds = actionTypeIds;
        emit actionTypeIdsChanged();
    }
}

QString BrowserItem::mediaIcon() const
{
    return m_mediaIcon;
}

void BrowserItem::setMediaIcon(const QString &mediaIcon)
{
    if (m_mediaIcon != mediaIcon) {
        m_mediaIcon = mediaIcon;
        emit mediaIconChanged();
    }
}
