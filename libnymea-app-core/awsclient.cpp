#include "awsclient.h"

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include <QUrlQuery>
#include <QJsonDocument>


extern "C" {
#include "connection/srp.h"
}

static QByteArray clientId = "8rjhfdlf9jf1suok2jcrltd6v";

AWSClient::AWSClient(QObject *parent) : QObject(parent)
{
    m_nam = new QNetworkAccessManager(this);
}

void AWSClient::login(const QString &username, const QString &password)
{
    if (m_srpUser != nullptr) {
        qWarning() << "Already logged in. Cannot log in again";
        return;
    }

    m_srpUser = srp_user_new(SRP_SHA256, SRP_NG_2048, username.toLocal8Bit(), (const unsigned char*)password.toLocal8Bit().data(), password.length(), nullptr ,nullptr);

    char *user;
    unsigned char *bytes_A;
    int len_A;
    srp_user_start_authentication(m_srpUser, (const char**)&user, (const unsigned char**)&bytes_A, &len_A);

    QUrl url("https://cognito-idp.eu-west-1.amazonaws.com/");

    QUrlQuery query;
    query.addQueryItem("Action", "InitiateAuth");
    query.addQueryItem("Version", "2016-04-18");
    url.setQuery(query);

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-amz-json-1.0");
    request.setRawHeader("Host", "cognito-idp.eu-west-1.amazonaws.com");
    request.setRawHeader("X-Amz-Target", "AWSCognitoIdentityProviderService.InitiateAuth");

    QVariantMap params;
    params.insert("AuthFlow", "USER_PASSWORD_AUTH");
    params.insert("ClientId", clientId);

    QVariantMap authParams;
    authParams.insert("USERNAME", username);
    authParams.insert("PASSWORD", password);

    params.insert("AuthParameters", authParams);
    QJsonDocument jsonDoc = QJsonDocument::fromVariant(params);

    QByteArray payload = jsonDoc.toJson(QJsonDocument::Compact);

    qDebug() << "Posting:\nURL:" << request.url().toString();
    qDebug() << "HEADERS:";
    foreach (const QByteArray &headerName, request.rawHeaderList()) {
        qDebug() << headerName << ":" << request.rawHeader(headerName);
    }
    qDebug().noquote() << "Payload:" << payload;

    QNetworkReply *reply = m_nam->post(request, payload);
    connect(reply, &QNetworkReply::finished, this, &AWSClient::initiateAuthReply);
}

void AWSClient::initiateAuthReply()
{
    QNetworkReply* reply = static_cast<QNetworkReply*>(sender());
    reply->deleteLater();
    QByteArray data = reply->readAll();
    qDebug() << "InitiateAuth reply" << reply->error() << reply->errorString() << qUtf8Printable(data);

    QJsonParseError error;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(data, &error);
    if (error.error != QJsonParseError::NoError) {
        qWarning() << "Failed to parse AWS login response" << error.errorString();
        return;
    }

    QVariantMap authenticationResult = jsonDoc.toVariant().toMap().value("AuthenticationResult").toMap();
    QByteArray accessToken = authenticationResult.value("AccessToken").toByteArray();
    QByteArray idToken = authenticationResult.value("IdToken").toByteArray();

    qDebug() << "Have acess token:" << accessToken;
    qDebug() << "have idToken:" << idToken;

    QUrl url("https://cognito-identity.eu-west-1.amazonaws.com/");

    QUrlQuery query;
    query.addQueryItem("Action", "GetId");
    query.addQueryItem("Version", "2016-06-30");
    url.setQuery(query);

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-amz-json-1.0");
    request.setRawHeader("Host", "cognito-identity.eu-west-1.amazonaws.com");
    request.setRawHeader("X-Amz-Target", "AWSCognitoIdentityService.GetId");

    QVariantMap logins;
    logins.insert("cognito-idp.eu-west-1.amazonaws.com/eu-west-1_6eX6YjmXr", idToken);

    QVariantMap params;
    params.insert("IdentityPoolId", "eu-west-1:108a174c-5786-40f9-966a-1a0cd33d6801");
    params.insert("Logins", logins);

    jsonDoc = QJsonDocument::fromVariant(params);
    QByteArray payload = jsonDoc.toJson(QJsonDocument::Compact);


    qDebug() << "Posting:\nURL:" << request.url().toString();
    qDebug() << "HEADERS:";
    foreach (const QByteArray &headerName, request.rawHeaderList()) {
        qDebug() << headerName << ":" << request.rawHeader(headerName);
    }
    qDebug().noquote() << "Payload:" << payload;

    reply = m_nam->post(request, payload);
    connect(reply, &QNetworkReply::finished, this, &AWSClient::getIdReply);
}

void AWSClient::getIdReply()
{
    QNetworkReply* reply = static_cast<QNetworkReply*>(sender());
    reply->deleteLater();
    QByteArray data = reply->readAll();
    qDebug() << "RespondToAuthChallenge reply" << reply->error() << reply->errorString() << qUtf8Printable(data);


//    QM
}
