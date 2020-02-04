#include "tokeninfo.h"

TokenInfo::TokenInfo(const QUuid &id, const QString &username, const QString &deviceName, const QDateTime &creationTime, QObject *parent):
    QObject(parent),
    m_id(id),
    m_username(username),
    m_deviceName(deviceName),
    m_creationTime(creationTime)
{

}

QUuid TokenInfo::id() const
{
    return m_id;
}

QString TokenInfo::username() const
{
    return m_username;
}

QString TokenInfo::deviceName() const
{
    return m_deviceName;
}

QDateTime TokenInfo::creationTime() const
{
    return m_creationTime;
}
