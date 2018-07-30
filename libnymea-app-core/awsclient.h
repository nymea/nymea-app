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
    void respondToAuthChallengeReply();

private:
    QNetworkAccessManager *m_nam = nullptr;
    SRPUser *m_srpUser = nullptr;

    void sign(QNetworkRequest &request);
};

#endif // AWSCLIENT_H
