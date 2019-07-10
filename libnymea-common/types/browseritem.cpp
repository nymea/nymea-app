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
