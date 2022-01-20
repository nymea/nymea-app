#ifndef USERINFO_H
#define USERINFO_H

#include <QObject>

class UserInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString username READ username NOTIFY usernameChanged)
    Q_PROPERTY(QString email READ email NOTIFY emailChanged)
    Q_PROPERTY(QString displayName READ displayName NOTIFY displayNameChanged)
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

    QString email() const;
    void setEmail(const QString &email);

    QString displayName() const;
    void setDisplayName(const QString &displayName);

    PermissionScopes scopes() const;
    void setScopes(PermissionScopes scopes);

    static QStringList scopesToList(PermissionScopes scopes);
    static PermissionScopes listToScopes(const QStringList &scopeList);

signals:
    void usernameChanged();
    void emailChanged();
    void displayNameChanged();
    void scopesChanged();

private:
    QString m_username;
    QString m_email;
    QString m_displayName;
    PermissionScopes m_scopes = PermissionScopeNone;

};

Q_DECLARE_METATYPE(UserInfo::PermissionScope)
Q_DECLARE_METATYPE(UserInfo::PermissionScopes)

#endif // USERINFO_H
