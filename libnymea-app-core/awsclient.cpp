#include "awsclient.h"

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include <QUrlQuery>
#include <QJsonDocument>
#include <QSettings>

static QByteArray clientId = "8rjhfdlf9jf1suok2jcrltd6v";

AWSClient::AWSClient(QObject *parent) : QObject(parent)
{
    m_nam = new QNetworkAccessManager(this);

    QSettings settings;
    settings.beginGroup("cloud");
    m_username = settings.value("username").toString();
    m_accessToken = settings.value("accessToken").toByteArray();
    m_idToken = settings.value("idToken").toByteArray();
}

bool AWSClient::isLoggedIn() const
{
    return !m_username.isEmpty() && !m_accessToken.isEmpty() && !m_idToken.isEmpty();
}

void AWSClient::login(const QString &username, const QString &password)
{
    m_username = username;

    QSettings settings;
    settings.remove("cloud");
    settings.beginGroup("cloud");
    settings.setValue("username", username);

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
    QNetworkReply *reply = m_nam->post(request, payload);
    connect(reply, &QNetworkReply::finished, this, &AWSClient::initiateAuthReply);
    qDebug() << "Logging in to AWS as user:" << username;
}

void AWSClient::initiateAuthReply()
{
    QNetworkReply* reply = static_cast<QNetworkReply*>(sender());
    reply->deleteLater();
    QByteArray data = reply->readAll();

    if (reply->error() != QNetworkReply::NoError) {
        qWarning() << "Error logging in to aws:" << reply->error() << reply->errorString() << qUtf8Printable(data);
        return;
    }

    QJsonParseError error;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(data, &error);
    if (error.error != QJsonParseError::NoError) {
        qWarning() << "Failed to parse AWS login response" << error.errorString();
        return;
    }

    QVariantMap authenticationResult = jsonDoc.toVariant().toMap().value("AuthenticationResult").toMap();

    m_accessToken = authenticationResult.value("AccessToken").toByteArray();
    m_idToken = authenticationResult.value("IdToken").toByteArray();
    QSettings settings;
    settings.beginGroup("cloud");
    settings.setValue("accessToken", m_accessToken);
    settings.setValue("idToken", m_idToken);

    qDebug() << "AWS login successful";
    emit isLoggedInChanged();

    return; // Why should we call GetId? Ask Luca

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
    logins.insert("cognito-idp.eu-west-1.amazonaws.com/eu-west-1_6eX6YjmXr", m_idToken);

    QVariantMap params;
    params.insert("IdentityPoolId", "eu-west-1:108a174c-5786-40f9-966a-1a0cd33d6801");
    params.insert("Logins", logins);

    jsonDoc = QJsonDocument::fromVariant(params);
    QByteArray payload = jsonDoc.toJson(QJsonDocument::Compact);

    reply = m_nam->post(request, payload);
    connect(reply, &QNetworkReply::finished, this, &AWSClient::getIdReply);
}

void AWSClient::getIdReply()
{
    QNetworkReply* reply = static_cast<QNetworkReply*>(sender());
    reply->deleteLater();
    QByteArray data = reply->readAll();
    qDebug() << "GetID reply" << reply->error() << reply->errorString() << qUtf8Printable(data);
}

void AWSClient::fetchDevices()
{
    QUrl url("https://z6368zhf2m.execute-api.eu-west-1.amazonaws.com/dev/devices");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("x-api-idToken", m_idToken);

    QNetworkReply *reply = m_nam->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        QByteArray data = reply->readAll();
        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "Error fetching cloud devices:" << reply->error() << reply->errorString() << qUtf8Printable(data);
            return;
        }
        QJsonParseError error;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(data, &error);
        if (error.error != QJsonParseError::NoError) {
            qWarning() << "Failed to parse JSON from server" << error.errorString() << qUtf8Printable(data);
            return;
        }
        QList<AWSDevice> ret;
        foreach (const QVariant &entry, jsonDoc.toVariant().toMap().value("devices").toList()) {
            AWSDevice d;
            d.id = entry.toMap().value("deviceId").toString();
            d.name = entry.toMap().value("name").toString();
            d.online = entry.toMap().value("online").toBool();
            ret.append(d);
        }
        emit devicesFetched(ret);
    });

}
