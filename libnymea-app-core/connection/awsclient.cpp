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
    m_password = settings.value("password").toString();
    m_accessToken = settings.value("accessToken").toByteArray();
    m_accessTokenExpiry = settings.value("accessTokenExpiry").toDateTime();
    m_idToken = settings.value("idToken").toByteArray();
    m_refreshToken = settings.value("refreshToken").toByteArray();

    m_identityId = settings.value("identityId").toByteArray();

    m_accessKeyId = settings.value("accessKeyId").toByteArray();
    m_secretKey = settings.value("secretKey").toByteArray();
    m_sessionToken = settings.value("sessionToken").toByteArray();
    m_sessionTokenExpiry = settings.value("sessionTokenExpiry").toDateTime();
}

bool AWSClient::isLoggedIn() const
{
    return !m_username.isEmpty() && !m_password.isEmpty();
}

QString AWSClient::username() const
{
    return m_username;
}

void AWSClient::login(const QString &username, const QString &password)
{
    m_username = username;
    // Ok... Please fogive me for this... AWS APIs are just unbearable... can't be bothered
    // any more to walk through another chain of calls in order to have the refreshToken working.
    // Will store the password in the config for now and re-login when the accessToken expires.
    // See: https://forums.aws.amazon.com/thread.jspa?threadID=287978
    m_password = password;

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
            m_username.clear();
            m_password.clear();
            return;
        }
        QByteArray data = reply->readAll();
        QJsonParseError error;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(data, &error);
        if (error.error != QJsonParseError::NoError) {
            qWarning() << "Failed to parse AWS login response" << error.errorString();
            m_username.clear();
            m_password.clear();
            return;
        }

        QVariantMap authenticationResult = jsonDoc.toVariant().toMap().value("AuthenticationResult").toMap();
        m_accessToken = authenticationResult.value("AccessToken").toByteArray();
        m_accessTokenExpiry = QDateTime::currentDateTime().addSecs(authenticationResult.value("ExpiresIn").toInt());
        m_idToken = authenticationResult.value("IdToken").toByteArray();
        m_refreshToken = authenticationResult.value("RefreshToken").toByteArray();

        QSettings settings;
        settings.remove("cloud");

        settings.beginGroup("cloud");
        settings.setValue("username", m_username);
        settings.setValue("password", m_password);
        settings.setValue("accessToken", m_accessToken);
        settings.setValue("accessTokenExpiry", m_accessTokenExpiry);
        settings.setValue("idToken", m_idToken);
        settings.setValue("refreshToken", m_refreshToken);

        qDebug() << "AWS login successful" << qUtf8Printable(jsonDoc.toJson(QJsonDocument::Indented));
        emit isLoggedInChanged();

        qDebug() << "Getting cognito ID";
        getId();
    });
}

void AWSClient::logout()
{
    m_username.clear();
    m_password.clear();
    QSettings settings;
    settings.remove("cloud");
    emit isLoggedInChanged();
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
        m_identityId = jsonDoc.toVariant().toMap().value("IdentityId").toByteArray();
        QSettings settings;
        settings.beginGroup("cloud");
        settings.setValue("identityId", m_identityId);

        qDebug() << "Received cognito identity id" << m_identityId;
        getCredentialsForIdentity(m_identityId);

    });
}

QByteArray AWSClient::idToken() const
{
    return m_idToken;
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
        m_sessionTokenExpiry = QDateTime::fromSecsSinceEpoch(credentialsMap.value("Expiration").toLongLong());

        QSettings settings;
        settings.beginGroup("cloud");
        settings.setValue("accessKeyId", m_accessKeyId);
        settings.setValue("secretKey", m_secretKey);
        settings.setValue("sessionToken", m_sessionToken);
        settings.setValue("sessionTokenExpiry", m_sessionTokenExpiry);

        qDebug() << "AWS Credentials for Identity received.";

        while (!m_callQueue.isEmpty()) {
            QueuedCall qc = m_callQueue.takeFirst();
            if (qc.method == "fetchDevices") {
                fetchDevices();
            } else if (qc.method == "postToMQTT") {
                postToMQTT(qc.boxId, qc.callback);
            }
        }
    });
}

bool AWSClient::tokensExpired() const
{
    return (m_accessTokenExpiry.addSecs(-10) < QDateTime::currentDateTime()) || (m_sessionTokenExpiry.addSecs(-10) < QDateTime::currentDateTime());
}

bool AWSClient::postToMQTT(const QString &boxId, std::function<void(bool)> callback)
{
    if (!isLoggedIn()) {
        qWarning() << "Cannot post to MQTT. Not logged in to AWS";
        return false;
    }
    if (tokensExpired()) {
        qDebug() << "Cannot post to MQTT. Need to refresh the tokens first";
        refreshAccessToken();
        m_callQueue.append(QueuedCall("postToMQTT", boxId, callback));
        return true; // So far it looks we're doing ok... let's return true
    }    
    QString host = "a2addxakg5juii.iot.eu-west-1.amazonaws.com";
    QString topic = QString("%1/%2/proxy").arg(boxId).arg(QString(m_identityId));

    // This is somehow broken in AWS...
    // The Signature needs to be created with having the topic percentage-encoded twice
    // while the actual request needs to go out with it only being encoded once.
    // Now one could think this is an issue in how the signature is made, but it can't really
    // be fixed there as this concerns only the actual topic, not /topics/
    // so we can't percentage-encode the whole path inside the signature helper...
    QString path = "/topics/" + topic.toUtf8().toPercentEncoding().toPercentEncoding() + "?qos=1";
    QString path1 = "/topics/" + topic.toUtf8().toPercentEncoding() + "?qos=1";

    QVariantMap params;
    params.insert("token", m_idToken);
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
    connect(reply, &QNetworkReply::finished, this, [reply, callback]() {
        reply->deleteLater();
        QByteArray data = reply->readAll();
        qDebug() << "post reply" << data;
        QJsonParseError error;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(data, &error);
        if (error.error != QJsonParseError::NoError) {
            qWarning() << "Failed to parse reply" << error.error << error.errorString() << data;
            callback(false);
            return;
        }
        if (jsonDoc.toVariant().toMap().value("message").toString() != "OK") {
            qWarning() << "Something went wrong posting to MQTT:" << jsonDoc.toVariant().toMap().value("message").toString();
            callback(false);
            return;
        }
        callback(true);

    });

    return true;
}

void AWSClient::fetchDevices()
{
    if (!isLoggedIn()) {
        qWarning() << "Not logged in at AWS. Can't fetch paired devices";
        return;
    }
    if (tokensExpired()) {
        qDebug() << "Cannot fetch devices. Need to refresh our tokens";
        refreshAccessToken();
        m_callQueue.append(QueuedCall("fetchDevices"));
        return;
    }
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
            ret.append(d);
        }
        emit devicesFetched(ret);

    });
}

void AWSClient::refreshAccessToken()
{
    if (!isLoggedIn()) {
        qDebug() << "Cannot refresh tokens. Not logged in to AWS";
        return;
    }

    // We should use REFRESH_TOKEN_AUTH to refresh our tokens but it's not working
    // https://forums.aws.amazon.com/thread.jspa?threadID=287978
    // Let's re-login instead with user & pass
    login(m_username, m_password);
    return;


    // Non-working block... Enable this if Amazon ever fixes their API...
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
    params.insert("ClientId", clientId);

    QVariantMap authParams;
    authParams.insert("REFRESH_TOKEN", m_refreshToken);

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

