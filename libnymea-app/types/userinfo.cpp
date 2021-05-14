#include "userinfo.h"

#include <QMetaEnum>
#include <QDebug>

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

UserInfo::PermissionScopes UserInfo::scopes() const
{
    return m_scopes;
}

void UserInfo::setScopes(PermissionScopes scopes)
{
    if (m_scopes != scopes) {
        m_scopes = scopes;
        emit scopesChanged();
    }
}

QStringList UserInfo::scopesToList(PermissionScopes scopes)
{
    QStringList ret;
    QMetaEnum metaEnum = QMetaEnum::fromType<PermissionScopes>();
    for (int i = 0; i < metaEnum.keyCount(); i++) {
        if (scopes.testFlag(static_cast<PermissionScope>(metaEnum.value(i)))) {
            ret << metaEnum.key(i);
        }
    }
    return ret;
}

UserInfo::PermissionScopes UserInfo::listToScopes(const QStringList &scopeList)
{
    PermissionScopes ret;
    QMetaEnum metaEnum = QMetaEnum::fromType<PermissionScopes>();
    for (int i = 0; i < metaEnum.keyCount(); i++) {
        if (scopeList.contains(metaEnum.key(i))) {
            ret.setFlag(static_cast<PermissionScope>(metaEnum.value(i)));
        }
    }
    return ret;
}
