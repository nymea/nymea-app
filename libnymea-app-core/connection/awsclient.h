#ifndef AWSCLIENT_H
#define AWSCLIENT_H

#include <QObject>
#include <QNetworkRequest>
#include <QDate>

class QNetworkAccessManager;

class AWSDevice {
public:
    QString id;
    QString name;
    bool online;
};

class AWSClient : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isLoggedIn READ isLoggedIn NOTIFY isLoggedInChanged)

public:
    explicit AWSClient(QObject *parent = nullptr);

    bool isLoggedIn() const;

    Q_INVOKABLE void login(const QString &username, const QString &password);

    Q_INVOKABLE void fetchDevices();

    Q_INVOKABLE void postToMQTT();
    Q_INVOKABLE void getId();

    QByteArray accessToken() const;

signals:
    void isLoggedInChanged();

    void devicesFetched(QList<AWSDevice> devices);

private:
    void refreshAccessToken();
    void getCredentialsForIdentity(const QString &identityId);
    void connectMQTT();

private:
    QNetworkAccessManager *m_nam = nullptr;

    QString m_username;
    QByteArray m_accessToken;
    QDateTime m_accessTokenExpiry;
    QByteArray m_idToken;
    QByteArray m_refreshToken;

    QByteArray m_accessKeyId;
    QByteArray m_secretKey;
    QByteArray m_sessionToken;
    QDateTime m_expirationDate;
};

#endif // AWSCLIENT_H
