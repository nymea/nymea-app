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
    Q_PROPERTY(QString username READ username NOTIFY isLoggedInChanged)

public:
    explicit AWSClient(QObject *parent = nullptr);

    bool isLoggedIn() const;
    QString username() const;

    Q_INVOKABLE void login(const QString &username, const QString &password);
    Q_INVOKABLE void logout();

    Q_INVOKABLE void fetchDevices();

    Q_INVOKABLE bool postToMQTT(const QString &boxId, std::function<void(bool)> callback);
    Q_INVOKABLE void getId();

    bool tokensExpired() const;
    QByteArray idToken() const;

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
    QString m_password;

    QByteArray m_accessToken;
    QDateTime m_accessTokenExpiry;
    QByteArray m_idToken;
    QByteArray m_refreshToken;

    QByteArray m_identityId;

    QByteArray m_accessKeyId;
    QByteArray m_secretKey;
    QByteArray m_sessionToken;
    QDateTime m_sessionTokenExpiry;

    class QueuedCall {
    public:
        QueuedCall(const QString &method): method(method) { }
        QueuedCall(const QString &method, const QString &boxId, std::function<void(bool)> callback): method(method), boxId(boxId), callback(callback) {}
        QString method;
        QString boxId;
        std::function<void(bool)> callback;
    };

    QList<QueuedCall> m_callQueue;
};

#endif // AWSCLIENT_H
