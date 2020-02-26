#include "userinfo.h"

UserInfo::UserInfo(QObject *parent):
    QObject(parent)
{

}

UserInfo::UserInfo(const QString &username, QObject *parent):
    QObject(parent),
    m_username(username)
{

}

QString UserInfo::username() const
{
    return m_username;
}

void UserInfo::setUsername(const QString &username)
{
    if (m_username != username) {
        m_username = username;
        emit usernameChanged();
    }
}
