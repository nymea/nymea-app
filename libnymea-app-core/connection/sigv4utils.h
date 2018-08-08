#ifndef SIGV4UTILS_H
#define SIGV4UTILS_H

#include <QString>
#include <QNetworkRequest>
#include <QNetworkAccessManager>

class SigV4Utils
{
public:
    SigV4Utils();

    static QByteArray getCurrentDateTime();


    static QByteArray getCanonicalQueryString(const QNetworkRequest &request, const QByteArray &accessKeyId, const QByteArray &secretAccessKey, const QByteArray &sessionToken, const QByteArray &region, const QByteArray &service, const QByteArray &payload);
    static QByteArray getCanonicalRequest(QNetworkAccessManager::Operation operation, const QNetworkRequest &request, const QByteArray &payload);
    static QByteArray getCanonicalHeaders(const QNetworkRequest &request);
    static QByteArray getCredentialScope(const QByteArray &algorithm, const QByteArray &dateTime, const QByteArray &region, const QByteArray &service);
    static QByteArray getStringToSign(const QByteArray &canonicalRequest, const QByteArray &dateTime, const QByteArray &region, const QByteArray &service);
    static QByteArray getSignatureKey(const QByteArray &key, const QByteArray &date, const QByteArray &region, const QByteArray &service);
    static QByteArray getSignature(const QByteArray &stringToSign, const QByteArray &secretAccessKey, const QByteArray &dateTime, const QString &region, const QString &service);
    static QByteArray getAuthorizationHeader(const QByteArray &accessKeyId, const QByteArray &dateTime, const QString &region, const QString &service, const QNetworkRequest &request, const QByteArray &signature);

};

#endif // SIGV4UTILS_H
