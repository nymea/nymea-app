#ifndef AWSCLIENT_H
#define AWSCLIENT_H

#include <QObject>
#include <QNetworkRequest>

class QNetworkAccessManager;
struct SRPUser;

class AWSClient : public QObject
{
    Q_OBJECT
public:
    explicit AWSClient(QObject *parent = nullptr);

    Q_INVOKABLE void login(const QString &username, const QString &password);

private slots:
    void initiateAuthReply();
    void getIdReply();

private:
    QByteArray createClaim(const QByteArray &secretBlock, const QByteArray &srpB, const QByteArray &salt);
    QByteArray getPasswordAuthenticationKey(const QByteArray &username, const QByteArray &password);
private:
    QNetworkAccessManager *m_nam = nullptr;
    SRPUser *m_srpUser = nullptr;

    void sign(QNetworkRequest &request);
};

#endif // AWSCLIENT_H
