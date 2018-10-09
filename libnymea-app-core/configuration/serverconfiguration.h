#ifndef SERVERCONFIGURATION_H
#define SERVERCONFIGURATION_H

#include <QObject>
#include <QHostAddress>
#include <QUuid>

class ServerConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id CONSTANT)
    Q_PROPERTY(QString address READ address CONSTANT)
    Q_PROPERTY(int port READ port CONSTANT)
    Q_PROPERTY(bool authenticationEnabled READ authenticationEnabled CONSTANT)
    Q_PROPERTY(bool sslEnabled READ sslEnabled CONSTANT)
public:
    explicit ServerConfiguration(const QString &id, const QHostAddress &address, int port, bool authEnabled, bool sslEnabled, QObject *parent = nullptr);

    QString id() const;
    QString address() const;
    int port() const;
    bool authenticationEnabled() const;
    bool sslEnabled() const;

private:
    QString m_id;
    QHostAddress m_hostAddress;
    int m_port;
    bool m_authEnabled;
    bool m_sslEnabled;
};

#endif // SERVERCONFIGURATION_H
