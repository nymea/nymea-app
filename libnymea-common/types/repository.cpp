#include "repository.h"

Repository::Repository(const QString &id, const QString &displayName, QObject *parent):
    QObject(parent),
    m_id(id),
    m_displayName(displayName)
{

}

QString Repository::id() const
{
    return m_id;
}

QString Repository::displayName() const
{
    return m_displayName;
}

bool Repository::enabled() const
{
    return m_enabled;
}

void Repository::setEnabled(bool enabled)
{
    if (m_enabled != enabled) {
        m_enabled = enabled;
        emit enabledChanged();
    }
}
