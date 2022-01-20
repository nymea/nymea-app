#ifndef TOKENINFO_H
#define TOKENINFO_H

#include <QObject>
#include <QUuid>
#include <QDateTime>

class TokenInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid id READ id CONSTANT)
    Q_PROPERTY(QString username READ username CONSTANT)
    Q_PROPERTY(QString deviceName READ deviceName CONSTANT)
    Q_PROPERTY(QDateTime creationTime READ creationTime CONSTANT)

public:
    explicit TokenInfo(const QUuid &id, const QString &username, const QString &deviceName, const QDateTime &creationTime, QObject *parent = nullptr);

    QUuid id() const;
    QString username() const;
    QString deviceName() const;
    QDateTime creationTime() const;

private:
    QUuid m_id;
    QString m_username;
    QString m_deviceName;
    QDateTime m_creationTime;
};

#endif // TOKENINFO_H
