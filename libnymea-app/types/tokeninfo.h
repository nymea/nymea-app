#ifndef TOKENINFO_H
#define TOKENINFO_H

#include <QObject>
#include <QUuid>
#include <QDateTime>

class TokenInfo : public QObject
{
    Q_OBJECT
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
