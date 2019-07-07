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
    m_displayName = displayName;
}

QString BrowserItem::description() const
{
    return m_description;
}

void BrowserItem::setDescription(const QString &description)
{
    m_description = description;
}

QString BrowserItem::icon() const
{
    return m_icon;
}

void BrowserItem::setIcon(const QString &icon)
{
    m_icon = icon;
}

QString BrowserItem::thumbnail() const
{
    return m_thumbnail;
}

void BrowserItem::setThumbnail(const QString &thumbnail)
{
    m_thumbnail = thumbnail;
}

bool BrowserItem::executable() const
{
    return m_executable;
}

void BrowserItem::setExecutable(bool executable)
{
    m_executable = executable;
}

bool BrowserItem::browsable() const
{
    return m_browsable;
}

void BrowserItem::setBrowsable(bool browsable)
{
    m_browsable = browsable;
}

QString BrowserItem::mediaIcon() const
{
    return m_mediaIcon;
}

void BrowserItem::setMediaIcon(const QString &mediaIcon)
{
    m_mediaIcon = mediaIcon;
}
