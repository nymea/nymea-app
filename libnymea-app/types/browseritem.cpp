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
