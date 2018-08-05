#ifndef AWSCLIENT_H
#define AWSCLIENT_H

#include <QObject>
#include <QNetworkRequest>

class QNetworkAccessManager;
struct SRPUser;

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

signals:
    void isLoggedInChanged();

    void devicesFetched(QList<AWSDevice> devices);

private slots:
    void initiateAuthReply();
    void getIdReply();

private:
    QNetworkAccessManager *m_nam = nullptr;

    QString m_username;
    QByteArray m_accessToken;
    QByteArray m_idToken;
};

#endif // AWSCLIENT_H
