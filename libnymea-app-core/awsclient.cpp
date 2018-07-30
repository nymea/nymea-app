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
    params.insert("AuthFlow", "USER_SRP_AUTH");
    params.insert("ClientId", clientId);

    QVariantMap authParams;
    authParams.insert("USERNAME", username);
    authParams.insert("SRP_A", QByteArray((char*)bytes_A, len_A).toHex());

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
    QVariantMap srpChallenge = jsonDoc.toVariant().toMap();
    QByteArray challengeName = srpChallenge.value("ChallengeName").toByteArray();
    QVariantMap challengeParams = srpChallenge.value("ChallengeParameters").toMap();
    QByteArray secretBlock = challengeParams.value("SECRET_BLOCK").toByteArray();
    QByteArray srpB = challengeParams.value("SRP_B").toByteArray();
    QByteArray username = challengeParams.value("USERNAME").toByteArray();
    char *bytes_M;
    int len_M;
    srp_user_process_challenge(m_srpUser, (const unsigned char*)secretBlock.data(), secretBlock.length(), (const unsigned char*)srpB.data(), srpB.length(), (const unsigned char**)&bytes_M, &len_M);

    QUrl url("https://cognito-idp.eu-west-1.amazonaws.com/");

    QUrlQuery query;
    query.addQueryItem("Action", "RespondToAuthChallenge");
    query.addQueryItem("Version", "2016-04-18");
    url.setQuery(query);

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-amz-json-1.0");
    request.setRawHeader("Host", "cognito-idp.eu-west-1.amazonaws.com");
    request.setRawHeader("X-Amz-Target", "AWSCognitoIdentityProviderService.RespondToAuthChallenge");

    QVariantMap params;
    params.insert("ChallengeName", challengeName.data());

    QVariantMap challengeResponses;
    challengeResponses.insert("PASSWORD_CLAIM_SIGNATURE", srpB.toHex().data());
    challengeResponses.insert("PASSWORD_CLAIM_SECRET_BLOCK", secretBlock.data());
    challengeResponses.insert("USERNAME", username);
    challengeResponses.insert("TIMESTAMP", QLocale("en").toString(QDateTime::currentDateTime().toUTC(), "ddd MMM d HH:mm:ss UTC yyyy"));
    params.insert("ChallengeResponses", challengeResponses);

    params.insert("ClientId", clientId);

    jsonDoc = QJsonDocument::fromVariant(params);
    QByteArray payload = jsonDoc.toJson(QJsonDocument::Compact);

    qDebug() << "Posting:\nURL:" << request.url().toString();
    qDebug() << "HEADERS:";
    foreach (const QByteArray &headerName, request.rawHeaderList()) {
        qDebug() << headerName << ":" << request.rawHeader(headerName);
    }
    qDebug().noquote() << "Payload:" << payload;

    reply = m_nam->post(request, payload);
    connect(reply, &QNetworkReply::finished, this, &AWSClient::respondToAuthChallengeReply);
}

void AWSClient::respondToAuthChallengeReply()
{
    QNetworkReply* reply = static_cast<QNetworkReply*>(sender());
    reply->deleteLater();
    QByteArray data = reply->readAll();
    qDebug() << "RespondToAuthChallenge reply" << reply->error() << reply->errorString() << qUtf8Printable(data);
}

void AWSClient::sign(QNetworkRequest &request)
{
    QCryptographicHash::Algorithm algorithm = QCryptographicHash::Sha256;

    QByteArray data = "AWS4-HMAC-SHA256 Credential=";
    request.setRawHeader("Authorization", data);
}
