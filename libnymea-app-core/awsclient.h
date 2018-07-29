#ifndef AWSCLIENT_H
#define AWSCLIENT_H

#include <QObject>
#include <QNetworkRequest>

class QNetworkAccessManager;

class AWSClient : public QObject
{
    Q_OBJECT
public:
    explicit AWSClient(QObject *parent = nullptr);

    Q_INVOKABLE void login();

private slots:
    void loginReply();

private:
    QNetworkAccessManager *m_nam = nullptr;

    void sign(QNetworkRequest &request);
};

#endif // AWSCLIENT_H
