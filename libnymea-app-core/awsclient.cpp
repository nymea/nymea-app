#include "awsclient.h"

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include <QUrlQuery>
#include <QJsonDocument>


extern "C" {
#include "connection/srp.h"
}

AWSClient::AWSClient(QObject *parent) : QObject(parent)
{
    m_nam = new QNetworkAccessManager(this);
}

void AWSClient::login()
{

    QString pass = "H22*xgemmmmm";
//    SRPUser* srpUser = srp_user_new(SRP_SHA256, SRP_NG_2048, "michael.zanetti@guh.io", (const unsigned char*)pass.toLocal8Bit().data(), pass.length(), nullptr ,nullptr);
    SRPUser* srpUser = srp_user_new(SRP_SHA256, SRP_NG_2048, "michael.zanetti@guh.io", (const unsigned char*)"H22*xgemmmmm", pass.length(), nullptr ,nullptr);

    QUrl url("https://cognito-idp.eu-west-1.amazonaws.com/");
//    QUrl url("https://iam.amazonaws.com/");

    QUrlQuery query;
    query.addQueryItem("Action", "InitiateAuth");
    query.addQueryItem("Version", "2016-04-18");
//    url.setQuery(query);

    QNetworkRequest request(url);

    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json; charset=utf-8");
//    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-amz-json-1.0");
//    request.setRawHeader("Action", "InitiateAuth");
    request.setRawHeader("Host", "cognito-idp.eu-west-1.amazonaws.com");
//    request.setRawHeader("x-amz-date", QDateTime::currentDateTime().toString(Qt::ISODate).toUtf8());
    request.setRawHeader("X-Amz-Date", QDateTime::currentDateTime().toString("yyyyMMddThhmmssZ").toUtf8());
    request.setRawHeader("X-Amz-Target", "CognitoIdentityServiceProvider.InitiateAuth");
//    request.setRawHeader("UserAgent", "None of your business");
//    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-amz-json-1.0");
    request.setRawHeader("Version", "2016-04-18");

    QVariantMap params;
    params.insert("AuthFlow", "USER_SRP_AUTH");
    params.insert("ClientId", "8rjhfdlf9jf1suok2jcrltd6v");
//    params.insert("Action", "InitiateAuth");
//    params.insert("Version", "2016-04-18");

    char *username;
    unsigned char *bytes_A;
    int len_A;
    srp_user_start_authentication(srpUser, (const char**)&username, (const unsigned char**)&bytes_A, &len_A);

    QVariantMap authParams;
    authParams.insert("USERNAME", username);
    authParams.insert("SRP_A", QByteArray((char*)bytes_A, len_A).toHex());

    params.insert("AuthParameters", authParams);
    QJsonDocument jsonDoc = QJsonDocument::fromVariant(params);

    qDebug() << "Posting:\nURL:" << request.url().toString();
    qDebug() << "HEADERS:";
    foreach (const QByteArray &headerName, request.rawHeaderList()) {
        qDebug() << headerName << ":" << request.rawHeader(headerName);
    }
    QByteArray payload = jsonDoc.toJson(QJsonDocument::Compact);
    qDebug().noquote() << "Payload:" << payload;
    QNetworkReply *reply = m_nam->post(request, payload);
//    QNetworkReply *reply = m_nam->post(request, "{}");
    connect(reply, &QNetworkReply::finished, this, &AWSClient::loginReply);
}

void AWSClient::loginReply()
{
    QNetworkReply* reply = static_cast<QNetworkReply*>(sender());
    qDebug() << "login reply" << reply->error() << reply->errorString() << reply->readAll();
}

void AWSClient::sign(QNetworkRequest &request)
{
    QCryptographicHash::Algorithm algorithm = QCryptographicHash::Sha256;

    QByteArray data = "AWS4-HMAC-SHA256 Credential=";
    request.setRawHeader("Authorization", data);
}
