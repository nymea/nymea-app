#ifndef USERINFO_H
#define USERINFO_H

#include <QObject>

class UserInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString username READ username NOTIFY usernameChanged)
public:
    explicit UserInfo(QObject *parent = nullptr);
    explicit UserInfo(const QString &username, QObject *parent = nullptr);

    QString username() const;
    void setUsername(const QString &username);

signals:
    void usernameChanged();

private:
    QString m_username;

};

#endif // USERINFO_H
