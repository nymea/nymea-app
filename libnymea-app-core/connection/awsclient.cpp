#include "awsclient.h"

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include <QUrlQuery>
#include <QJsonDocument>
#include <QSettings>

#include "qmqtt.h"
#include "sigv4utils.h"

static QByteArray clientId = "8rjhfdlf9jf1suok2jcrltd6v";
static QByteArray region = "eu-west-1";
//static QByteArray service = "iotdevicegateway";
static QByteArray service = "iotdata";

AWSClient::AWSClient(QObject *parent) : QObject(parent)
{
    m_nam = new QNetworkAccessManager(this);

    QSettings settings;
    settings.beginGroup("cloud");
    m_username = settings.value("username").toString();
    m_accessToken = settings.value("accessToken").toByteArray();
    m_accessTokenExpiry = settings.value("accessTokenExpiry").toDateTime();
    m_idToken = settings.value("idToken").toByteArray();
    m_refreshToken = settings.value("refreshToken").toByteArray();

    m_accessKeyId = settings.value("accessKeyId").toByteArray();
    m_secretKey = settings.value("secretKey").toByteArray();
    m_sessionToken = settings.value("sessionToken").toByteArray();

//    if (m_accessTokenExpiry < QDateTime::currentDateTime() && !m_refreshToken.isEmpty()) {
        refreshAccessToken();
//    }
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

    qDebug() << "Logging in to AWS as user:" << username;

    QNetworkReply *reply = m_nam->post(request, payload);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "Error logging in to aws:" << reply->error() << reply->errorString();
            return;
        }
        QByteArray data = reply->readAll();
        QJsonParseError error;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(data, &error);
        if (error.error != QJsonParseError::NoError) {
            qWarning() << "Failed to parse AWS login response" << error.errorString();
            return;
        }

        QVariantMap authenticationResult = jsonDoc.toVariant().toMap().value("AuthenticationResult").toMap();
        m_accessToken = authenticationResult.value("AccessToken").toByteArray();
        m_accessTokenExpiry = QDateTime::currentDateTime().addSecs(authenticationResult.value("ExpiresIn").toInt());
        m_idToken = authenticationResult.value("IdToken").toByteArray();
        m_refreshToken = authenticationResult.value("RefreshToken").toByteArray();

        QSettings settings;
        settings.beginGroup("cloud");
        settings.setValue("accessToken", m_accessToken);
        settings.setValue("accessTokenExpiry", m_accessTokenExpiry);
        settings.setValue("idToken", m_idToken);
        settings.setValue("refreshToken", m_refreshToken);

        qDebug() << "AWS login successful" << qUtf8Printable(jsonDoc.toJson(QJsonDocument::Indented));
        emit isLoggedInChanged();

    });
}

void AWSClient::getId()
{
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

    QJsonDocument jsonDoc = QJsonDocument::fromVariant(params);
    QByteArray payload = jsonDoc.toJson(QJsonDocument::Compact);

    QNetworkReply *reply = m_nam->post(request, payload);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "Error calling GetId" << reply->error() << reply->errorString();
            return;
        }
        QByteArray data = reply->readAll();
        QJsonParseError error;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(data, &error);
        if (error.error != QJsonParseError::NoError) {
            qWarning() << "Error parsing json reply for GetId" << error.errorString();
            return;
        }
        QByteArray identityId = jsonDoc.toVariant().toMap().value("IdentityId").toByteArray();

        qDebug() << "Received cognito identity id" << identityId;
        getCredentialsForIdentity(identityId);

    });
}

void AWSClient::getCredentialsForIdentity(const QString &identityId)
{
    QUrl url("https://cognito-identity.eu-west-1.amazonaws.com/");

    QUrlQuery query;
    query.addQueryItem("Action", "GetCredentialsForIdentity");
    query.addQueryItem("Version", "2016-06-30");
    url.setQuery(query);

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-amz-json-1.0");
    request.setRawHeader("Host", "cognito-identity.eu-west-1.amazonaws.com");
    request.setRawHeader("X-Amz-Target", "AWSCognitoIdentityService.GetCredentialsForIdentity");

    QVariantMap logins;
    logins.insert("cognito-idp.eu-west-1.amazonaws.com/eu-west-1_6eX6YjmXr", m_idToken);

    QVariantMap params;
    params.insert("IdentityId", identityId);
    params.insert("Logins", logins);

    QJsonDocument jsonDoc = QJsonDocument::fromVariant(params);
    QByteArray payload = jsonDoc.toJson(QJsonDocument::Compact);

    qDebug() << "Calling GetCredentialsForIdentity:" <<  request.url();
    qDebug() << "Headers:";
    foreach (const QByteArray &headerName, request.rawHeaderList()) {
        qDebug() << headerName << ":" << request.rawHeader(headerName);
    }
    qDebug() << "Payload:" << qUtf8Printable(payload);

    QNetworkReply *reply = m_nam->post(request, payload);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "Error calling GetCredentialsForIdentity" << reply->errorString();
            return;
        }
        QByteArray data = reply->readAll();
        QJsonParseError error;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(data, &error);
        if (error.error != QJsonParseError::NoError) {
            qWarning() << "Error parsing JSON reply from GetCredentialsForIdentity" << error.errorString();
            return;
        }
        QVariantMap credentialsMap = jsonDoc.toVariant().toMap().value("Credentials").toMap();

        m_accessKeyId = credentialsMap.value("AccessKeyId").toByteArray();
        m_secretKey = credentialsMap.value("SecretKey").toByteArray();
        m_sessionToken = credentialsMap.value("SessionToken").toByteArray();
        m_expirationDate = QDateTime::fromSecsSinceEpoch(credentialsMap.value("Expiration").toLongLong());

        QSettings settings;
        settings.beginGroup("cloud");
        settings.setValue("accessKeyId", m_accessKeyId);
        settings.setValue("secretKey", m_secretKey);
        settings.setValue("sessionToken", m_sessionToken);

        qDebug() << "AWS Credentials for Identity received.";
//        qDebug() << "Raw GetCredentialsForIdentity reply:" << qUtf8Printable(data);
//        qDebug() << "GetCredentialsForIdentity reply: \nAccess Key ID:" << m_accessKeyId << "\nSecret Key:" << m_secretKey << "\nsessionkey:" << m_sessionToken << "\nExpiration:" << m_expirationDate;
    });
}

void AWSClient::connectMQTT()
{

    QString host = "a2addxakg5juii.iot.eu-west-1.amazonaws.com";
    QString uri = "/mqtt";

    QNetworkRequest request(QUrl("wss://" + host + uri));
    request.setRawHeader("Host", host.toUtf8());

    QByteArray dateTime = SigV4Utils::getCurrentDateTime();
//    QByteArray canonicalQueryString = SigV4Utils::getCanonicalQueryString(request, m_accessKeyId, m_secretKey, m_sessionToken, region, service, QByteArray());
    QByteArray canonicalQueryString = SigV4Utils::getCanonicalQueryString(request, m_accessKeyId, m_secretKey, QByteArray(), region, service, QByteArray());

    QString signedRequestUrl = "wss://" + host + uri + '?' + canonicalQueryString;

    qDebug() << "Connecting MQTT to" << signedRequestUrl;

    QMQTT::Client *mqttClient = new QMQTT::Client(signedRequestUrl, QString(clientId), QWebSocketProtocol::VersionLatest, false);
    mqttClient->setClientId(QString(clientId));
    mqttClient->setPort(443);
    mqttClient->setVersion(QMQTT::V3_1_1);

    connect(mqttClient, &QMQTT::Client::connected, this, []{
        qDebug() << "MQTT connected";
    });
    connect(mqttClient, &QMQTT::Client::disconnected, this, []{
        qDebug() << "MQTT disconnected";
    });
    connect(mqttClient, &QMQTT::Client::error, this, [](const QMQTT::ClientError error){
        qDebug() << "MQTT error" << error;
    });
    mqttClient->connectToHost();
}

void AWSClient::postToMQTT(const QString &token)
{
    QString host = "a2addxakg5juii.iot.eu-west-1.amazonaws.com";
    QString topic = "850593e9-f2ab-4e89-913a-16f848d48867/eu-west-1:88c8b0f1-3f26-46cb-81f3-ccc37dcb543a/proxy";

    // This is somehow broken in AWS...
    // The Signature needs to be created with having the topic percentage-encoded twice
    // while the actual request needs to go out with it only being encoded once.
    // Now one could think this is an issue in how the signature is made, but it can't really
    // be fixed there as this concerns only the actual topic, not /topics/
    // so we can't percentage-encode the whole path inside the signature helper...
    QString path = "/topics/" + topic.toUtf8().toPercentEncoding().toPercentEncoding() + "?qos=0";
    QString path1 = "/topics/" + topic.toUtf8().toPercentEncoding() + "?qos=0";

    QVariantMap params;
    params.insert("token", token);
    params.insert("timestamp", QDateTime::currentDateTime().toSecsSinceEpoch());
    QByteArray payload = QJsonDocument::fromVariant(params).toJson(QJsonDocument::Compact);


    QNetworkRequest request("https://" + host + path);
    request.setRawHeader("content-type", "application/json");
    request.setRawHeader("host", host.toUtf8());

    SigV4Utils::signRequest(QNetworkAccessManager::PostOperation, request, region, service, m_accessKeyId, m_secretKey, m_sessionToken, payload);

    // Workaround MQTT broker url weirdness as described above
    request.setUrl("https://" + host + path1);

    qDebug() << "Posting to MQTT:" << request.url().toString();
    qDebug() << "HEADERS:";
    foreach (const QByteArray &headerName, request.rawHeaderList()) {
        qDebug() << headerName << ":" << request.rawHeader(headerName);
    }
    qDebug() << "Payload:" << payload;
    QNetworkReply *reply = m_nam->post(request, payload);
    connect(reply, &QNetworkReply::finished, this, [reply]() {
        reply->deleteLater();
        qDebug() << "post reply" << reply->readAll();
    });
}

void AWSClient::fetchDevices()
{
    qDebug() << "Fetching cloud devices";
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
            d.token = m_accessToken;
            ret.append(d);
        }
        emit devicesFetched(ret);



    });

}

QByteArray AWSClient::accessToken() const
{
    return m_accessToken;
}

void AWSClient::refreshAccessToken()
{
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
    params.insert("AuthFlow", "REFRESH_TOKEN_AUTH");
//    params.insert("AuthFlow", "USER_PASSWORD_AUTH");
    params.insert("ClientId", clientId);

    QVariantMap authParams;
    authParams.insert("REFRESH_TOKEN", m_refreshToken);
//    authParams.insert("USERNAME", m_username);
//    authParams.insert("PASSWORD", "H22*xgemmmmm");

    params.insert("AuthParameters", authParams);

    QJsonDocument jsonDoc = QJsonDocument::fromVariant(params);
    QByteArray payload = jsonDoc.toJson(QJsonDocument::Compact);

    qDebug() << "Refreshing AWS token for user:" << m_username << qUtf8Printable(payload);

    QNetworkReply *reply = m_nam->post(request, payload);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "Error logging in to aws:" << reply->error() << reply->errorString();
            return;
        }
        QByteArray data = reply->readAll();
        QJsonParseError error;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(data, &error);
        if (error.error != QJsonParseError::NoError) {
            qWarning() << "Failed to parse AWS login response" << error.errorString();
            return;
        }

//        QVariantMap authenticationResult = jsonDoc.toVariant().toMap().value("AuthenticationResult").toMap();
//        m_accessToken = authenticationResult.value("AccessToken").toByteArray();
//        m_accessTokenExpiry = QDateTime::currentDateTime().addSecs(authenticationResult.value("ExpiresIn").toInt());
//        m_idToken = authenticationResult.value("IdToken").toByteArray();
//        m_refreshToken = authenticationResult.value("RefreshToken").toByteArray();

//        QSettings settings;
//        settings.beginGroup("cloud");
//        settings.setValue("accessToken", m_accessToken);
//        settings.setValue("accessTokenExpiry", m_accessTokenExpiry);
//        settings.setValue("idToken", m_idToken);
//        settings.setValue("refreshToken", m_refreshToken);

        qDebug() << "AWS login successful" << qUtf8Printable(jsonDoc.toJson(QJsonDocument::Indented));
        emit isLoggedInChanged();

    });
}

