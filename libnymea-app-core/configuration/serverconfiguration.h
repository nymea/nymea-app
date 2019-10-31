#ifndef SERVERCONFIGURATION_H
#define SERVERCONFIGURATION_H

#include <QObject>
#include <QHostAddress>
#include <QUuid>

class ServerConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id CONSTANT)
    Q_PROPERTY(QString address READ address WRITE setAddress NOTIFY addressChanged)
    Q_PROPERTY(int port READ port WRITE setPort NOTIFY portChanged)
    Q_PROPERTY(bool authenticationEnabled READ authenticationEnabled WRITE setAuthenticationEnabled NOTIFY authenticationEnabledChanged)
    Q_PROPERTY(bool sslEnabled READ sslEnabled WRITE setSslEnabled NOTIFY sslEnabledChanged)

public:
    explicit ServerConfiguration(const QString &id, const QHostAddress &address = QHostAddress(), int port = 0, bool authEnabled = false, bool sslEnabled = false, QObject *parent = nullptr);

    QString id() const;

    QString address() const;
    void setAddress(const QString &address);

    int port() const;
    void setPort(int port);

    bool authenticationEnabled() const;
    void setAuthenticationEnabled(bool authenticationEnabled);

    bool sslEnabled() const;
    void setSslEnabled(bool sslEnabled);

    Q_INVOKABLE virtual ServerConfiguration* clone() const;

signals:
    void addressChanged();
    void portChanged();
    void authenticationEnabledChanged();
    void sslEnabledChanged();

private:
    QString m_id;
    QHostAddress m_hostAddress;
    int m_port;
    bool m_authEnabled;
    bool m_sslEnabled;
};

class WebServerConfiguration: public ServerConfiguration
{
    Q_OBJECT
    Q_PROPERTY(QString publicFolder READ publicFolder WRITE setPublicFolder NOTIFY publicFolderChanged)
public:
    explicit WebServerConfiguration(const QString &id, const QHostAddress &address = QHostAddress(), int port = 0, bool authEnabled = false, bool sslEnabled = false, QObject *parent = nullptr)
        : ServerConfiguration(id, address, port, authEnabled, sslEnabled, parent) {}

    QString publicFolder() const;
    void setPublicFolder(const QString &publicFolder);

    Q_INVOKABLE ServerConfiguration* clone() const override;

signals:
    void publicFolderChanged();

private:
    QString m_publicFolder;
};

#endif // SERVERCONFIGURATION_H
