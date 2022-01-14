#ifndef USERINFO_H
#define USERINFO_H

#include <QObject>

class UserInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString username READ username NOTIFY usernameChanged)
    Q_PROPERTY(PermissionScopes scopes READ scopes NOTIFY scopesChanged)
public:
    enum PermissionScope {
        PermissionScopeNone             = 0x0000,
        PermissionScopeControlThings    = 0x0001,
        PermissionScopeConfigureThings  = 0x0003,
        PermissionScopeExecuteRules     = 0x0010,
        PermissionScopeConfigureRules   = 0x0030,
        PermissionScopeAdmin            = 0xFFFF,
    };
    Q_DECLARE_FLAGS(PermissionScopes, PermissionScope)
    Q_FLAG(PermissionScopes)

    explicit UserInfo(QObject *parent = nullptr);
    explicit UserInfo(const QString &username, QObject *parent = nullptr);

    QString username() const;
    void setUsername(const QString &username);

    PermissionScopes scopes() const;
    void setScopes(PermissionScopes scopes);

    static QStringList scopesToList(PermissionScopes scopes);
    static PermissionScopes listToScopes(const QStringList &scopeList);

signals:
    void usernameChanged();
    void scopesChanged();

private:
    QString m_username;
    PermissionScopes m_scopes = PermissionScopeNone;

};

Q_DECLARE_METATYPE(UserInfo::PermissionScope)
Q_DECLARE_METATYPE(UserInfo::PermissionScopes)

#endif // USERINFO_H
