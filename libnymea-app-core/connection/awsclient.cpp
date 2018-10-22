#include "awsclient.h"

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include <QUrlQuery>
#include <QJsonDocument>
#include <QSettings>
#include <QUuid>

#include "sigv4utils.h"

AWSClient* AWSClient::s_instance = nullptr;

// This is Symantec's root CA certificate and most platforms should
// have this in their certificate storage already, but as we can't
// be certain about the core's setup, let's deploy it ourselves.
static QByteArray rootCA = "-----BEGIN CERTIFICATE-----\n\
MIIE0zCCA7ugAwIBAgIQGNrRniZ96LtKIVjNzGs7SjANBgkqhkiG9w0BAQUFADCB\n\
yjELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMR8wHQYDVQQL\n\
ExZWZXJpU2lnbiBUcnVzdCBOZXR3b3JrMTowOAYDVQQLEzEoYykgMjAwNiBWZXJp\n\
U2lnbiwgSW5jLiAtIEZvciBhdXRob3JpemVkIHVzZSBvbmx5MUUwQwYDVQQDEzxW\n\
ZXJpU2lnbiBDbGFzcyAzIFB1YmxpYyBQcmltYXJ5IENlcnRpZmljYXRpb24gQXV0\n\
aG9yaXR5IC0gRzUwHhcNMDYxMTA4MDAwMDAwWhcNMzYwNzE2MjM1OTU5WjCByjEL\n\
MAkGA1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMR8wHQYDVQQLExZW\n\
ZXJpU2lnbiBUcnVzdCBOZXR3b3JrMTowOAYDVQQLEzEoYykgMjAwNiBWZXJpU2ln\n\
biwgSW5jLiAtIEZvciBhdXRob3JpemVkIHVzZSBvbmx5MUUwQwYDVQQDEzxWZXJp\n\
U2lnbiBDbGFzcyAzIFB1YmxpYyBQcmltYXJ5IENlcnRpZmljYXRpb24gQXV0aG9y\n\
aXR5IC0gRzUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCvJAgIKXo1\n\
nmAMqudLO07cfLw8RRy7K+D+KQL5VwijZIUVJ/XxrcgxiV0i6CqqpkKzj/i5Vbex\n\
t0uz/o9+B1fs70PbZmIVYc9gDaTY3vjgw2IIPVQT60nKWVSFJuUrjxuf6/WhkcIz\n\
SdhDY2pSS9KP6HBRTdGJaXvHcPaz3BJ023tdS1bTlr8Vd6Gw9KIl8q8ckmcY5fQG\n\
BO+QueQA5N06tRn/Arr0PO7gi+s3i+z016zy9vA9r911kTMZHRxAy3QkGSGT2RT+\n\
rCpSx4/VBEnkjWNHiDxpg8v+R70rfk/Fla4OndTRQ8Bnc+MUCH7lP59zuDMKz10/\n\
NIeWiu5T6CUVAgMBAAGjgbIwga8wDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8E\n\
BAMCAQYwbQYIKwYBBQUHAQwEYTBfoV2gWzBZMFcwVRYJaW1hZ2UvZ2lmMCEwHzAH\n\
BgUrDgMCGgQUj+XTGoasjY5rw8+AatRIGCx7GS4wJRYjaHR0cDovL2xvZ28udmVy\n\
aXNpZ24uY29tL3ZzbG9nby5naWYwHQYDVR0OBBYEFH/TZafC3ey78DAJ80M5+gKv\n\
MzEzMA0GCSqGSIb3DQEBBQUAA4IBAQCTJEowX2LP2BqYLz3q3JktvXf2pXkiOOzE\n\
p6B4Eq1iDkVwZMXnl2YtmAl+X6/WzChl8gGqCBpH3vn5fJJaCGkgDdk+bW48DW7Y\n\
5gaRQBi5+MHt39tBquCWIMnNZBU4gcmU7qKEKQsTb47bDN0lAtukixlE0kF6BWlK\n\
WE9gyn6CagsCqiUXObXbf+eEZSqVir2G3l6BFoMtEMze/aiCKm0oHw0LxOXnGiYZ\n\
4fQRbxC1lfznQgUy286dUV4otp6F01vvpX1FQHKOtw5rDgb7MzVIcbidJ4vEZV8N\n\
hnacRHr2lVz2XTIIM6RUthg/aFzyQkqFOFSDX9HoLPKsEdao7WNq\n\
-----END CERTIFICATE-----\n\
";

AWSClient::AWSClient(QObject *parent) : QObject(parent),
    m_devices(new AWSDevices(this))
{
    m_nam = new QNetworkAccessManager(this);

#ifdef Q_OS_ANDROID
    QString pushSystem = "GCM";
#elif defined Q_OS_IOS
    QString pushSystem = "APNS";
#else
    QString pushSystem = "";
#endif

    AWSConfiguration config;
    // Community environment
    config.clientId = "35duli0b13c7pet5k4bcv8pbu";
    config.poolId = "eu-west-1_WZVsaBsaY";
    config.identityPoolId = "eu-west-1:17449947-1a2f-4dda-aa49-7c5b1eec78d7";
    config.certificateEndpoint = "https://communityservice-cloud.nymea.io/certificatews/certificate";
    config.certificateApiKey = "aIRQv4yDdF6ASq12X1CPp7b6MpkdODfI3AOjOnkE";
    config.certificateVendorId = "d399290a-0599-4895-b4c3-34d2bdb579f4";
    config.mqttEndpoint = "a2d0ba9572wepp.iot.eu-west-1.amazonaws.com";
    config.region = "eu-west-1";
    config.apiEndpoint = "api-cloud.guh.io";
    config.pushNotificationSystem = pushSystem;
    m_configs.insert("Community", config);

    // Testing environment
    config.clientId = "8rjhfdlf9jf1suok2jcrltd6v";
    config.poolId = "eu-west-1_6eX6YjmXr";
    config.identityPoolId = "eu-west-1:108a174c-5786-40f9-966a-1a0cd33d6801";
    config.certificateEndpoint = "https://testcommunityservice-cloud.nymea.io/certificatews/certificate";
    config.certificateApiKey = "VhmAUy75eZ9jXaUEjgWZh9PpSIykPGBK7AZFPimh";
    config.certificateVendorId = "testVendor001";
    config.mqttEndpoint = "a2addxakg5juii.iot.eu-west-1.amazonaws.com";
    config.region = "eu-west-1";
    config.apiEndpoint = "testapi-cloud.guh.io";
    config.pushNotificationSystem = pushSystem == "APNS" ? pushSystem + "_SANDBOX" : pushSystem;
    m_configs.insert("Testing", config);

    // Marantec environment
    config.clientId = "7rf6da8pcqi1qi8tp1evf933h2";
    config.poolId = "eu-west-1_d4DdcqKJ8";
    config.identityPoolId = "eu-west-1:d32f6d94-caae-4f08-a193-f9fba8652646";
    // Generating certificates is not supported for the Marantec environment
    config.certificateEndpoint = "";
    config.certificateApiKey = "";
    config.certificateVendorId = "";
    config.mqttEndpoint = "a27q7a2x15m8h3.iot.eu-west-1.amazonaws.com";
    config.region = "eu-west-1";
    config.apiEndpoint = "api-cloud.guh.io";
    config.pushNotificationSystem = pushSystem;
    m_configs.insert("Marantec", config);

    QSettings settings;
    settings.beginGroup("cloud");
    m_username = settings.value("username").toString();
    m_userId = settings.value("userId").toString();
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

AWSClient *AWSClient::instance()
{
    if (!s_instance) {
        s_instance = new AWSClient();
    }
    return s_instance;
}

bool AWSClient::isLoggedIn() const
{
    return !m_userId.isEmpty() && !m_username.isEmpty() && !m_password.isEmpty();
}

QString AWSClient::username() const
{
    return m_username;
}

QString AWSClient::userId() const
{
    return m_userId;
}

AWSDevices *AWSClient::awsDevices() const
{
    return m_devices;
}

bool AWSClient::confirmationPending() const
{
    return m_confirmationPending;
}

void AWSClient::login(const QString &username, const QString &password, int attempt)
{
    if (m_loginInProgress) {
        qWarning() << "Login already pending...";
        return;
    }
    m_loginInProgress = true;

    m_username = username;
    // Due to an issue in AWS apis it's very complex to use the refresh token. Taking a shortcut here for now:
    // Will store the password in the config for now and re-login when the accessToken expires.
    // See: https://forums.aws.amazon.com/thread.jspa?threadID=287978
    // Ideally we'd use the refresh token and not store the password at all (see: refreshAccessToken())
    m_password = password;

    QString host = QString("cognito-idp.%1.amazonaws.com").arg(m_configs.value(m_usedConfig).region);
    QUrl url(QString("https://%1/").arg(host));

    QUrlQuery query;
    query.addQueryItem("Action", "InitiateAuth");
    query.addQueryItem("Version", "2016-04-18");
    url.setQuery(query);

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-amz-json-1.0");
    request.setRawHeader("Host", host.toUtf8());
    request.setRawHeader("X-Amz-Target", "AWSCognitoIdentityProviderService.InitiateAuth");

    QVariantMap params;
    params.insert("AuthFlow", "USER_PASSWORD_AUTH");
    params.insert("ClientId", m_configs.value(m_usedConfig).clientId);

    QVariantMap authParams;
    authParams.insert("USERNAME", username);
    authParams.insert("PASSWORD", password);

    params.insert("AuthParameters", authParams);

    QJsonDocument jsonDoc = QJsonDocument::fromVariant(params);
    QByteArray payload = jsonDoc.toJson(QJsonDocument::Compact);

    qDebug() << "Logging in to AWS as user:" << username;

    QNetworkReply *reply = m_nam->post(request, payload);
    connect(reply, &QNetworkReply::finished, this, [this, reply, username, password, attempt]() {
        reply->deleteLater();
        m_loginInProgress = false;
        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "Error logging in to aws:" << reply->error() << reply->errorString();
            if (attempt < 3) {
                login(username, password, attempt+1);
                return;
            }
            m_username.clear();
            m_password.clear();
            emit loginResult(LoginErrorUnknownError);
            return;
        }
        QByteArray data = reply->readAll();
        QJsonParseError error;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(data, &error);
        if (error.error != QJsonParseError::NoError) {
            qWarning() << "Failed to parse AWS login response" << error.errorString();
            m_username.clear();
            m_password.clear();
            emit loginResult(LoginErrorUnknownError);
            return;
        }

        QVariantMap authenticationResult = jsonDoc.toVariant().toMap().value("AuthenticationResult").toMap();
        m_accessToken = authenticationResult.value("AccessToken").toByteArray();
        m_accessTokenExpiry = QDateTime::currentDateTime().addSecs(authenticationResult.value("ExpiresIn").toInt());
        m_idToken = authenticationResult.value("IdToken").toByteArray();
        m_refreshToken = authenticationResult.value("RefreshToken").toByteArray();

        qDebug() << "AWS ID token" << m_idToken;
        QList<QByteArray> jwtParts = m_idToken.split('.');
        if (jwtParts.count() != 3) {
            qWarning() << "JWT token doesn't have 3 parts";
            return;
        }
//        qDebug() << "decoded header:" << QByteArray::fromBase64(jwtParts.at(0));
//        qDebug() << "decoded payload:" << QByteArray::fromBase64(jwtParts.at(1));
        QJsonDocument tokenPayloadJsonDoc = QJsonDocument::fromJson(QByteArray::fromBase64(jwtParts.at(1)));
        m_userId = tokenPayloadJsonDoc.toVariant().toMap().value("cognito:username").toByteArray();

        qDebug() << "Getting cognito ID";
        getId();
    });
}

void AWSClient::logout()
{
    m_userId.clear();
    m_username.clear();
    m_password.clear();
    m_devices->clear();
    QSettings settings;
    settings.remove("cloud");
    emit isLoggedInChanged();
}

void AWSClient::signup(const QString &username, const QString &password)
{
    m_userId = QUuid::createUuid().toString().remove(QRegExp("[{}]"));
    m_username = username;
    m_password = password;

    QString host = QString("cognito-idp.%1.amazonaws.com").arg(m_configs.value(m_usedConfig).region);
    QUrl url(QString("https://%1/").arg(host));

    QUrlQuery query;
    query.addQueryItem("Action", "SignUp");
    query.addQueryItem("Version", "2016-04-18");
    url.setQuery(query);

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-amz-json-1.0");
    request.setRawHeader("Host", host.toUtf8());
    request.setRawHeader("X-Amz-Target", "AWSCognitoIdentityProviderService.SignUp");

    QVariantMap params;
    params.insert("ClientId", m_configs.value(m_usedConfig).clientId);
    params.insert("Username", m_userId);
    params.insert("Password", password);

    QVariantMap emailAttribute;
    emailAttribute.insert("Name", "email");
    emailAttribute.insert("Value", username);

    QVariantList userAttributes;
    userAttributes.append(emailAttribute);
    params.insert("UserAttributes", userAttributes);

    QJsonDocument jsonDoc = QJsonDocument::fromVariant(params);
    QByteArray payload = jsonDoc.toJson(QJsonDocument::Compact);

    qDebug() << "Signing up to AWS as user:" << username << payload;

    QNetworkReply *reply = m_nam->post(request, payload);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        QByteArray data = reply->readAll();
        reply->deleteLater();
        qDebug() << "AWS signup reply:" << data;

        if (reply->error() == QNetworkReply::ProtocolInvalidOperationError) {
            emit signupResult(LoginErrorInvalidUserOrPass);
            return;
        }

        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "Error signing up to aws:" << reply->error() << reply->errorString();
            m_username.clear();
            m_password.clear();
            emit signupResult(LoginErrorUnknownError);
            return;
        }

        emit signupResult(LoginErrorNoError);

        m_confirmationPending = true;
        emit confirmationPendingChanged();
    });
}

void AWSClient::confirmRegistration(const QString &code)
{
    QString host = QString("cognito-idp.%1.amazonaws.com").arg(m_configs.value(m_usedConfig).region);
    QUrl url(QString("https://%1/").arg(host));

    QUrlQuery query;
    query.addQueryItem("Action", "ConfirmSignUp");
    query.addQueryItem("Version", "2016-04-18");
    url.setQuery(query);

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-amz-json-1.0");
    request.setRawHeader("Host", host.toUtf8());
    request.setRawHeader("X-Amz-Target", "AWSCognitoIdentityProviderService.ConfirmSignUp");

    QVariantMap params;
    params.insert("ClientId", m_configs.value(m_usedConfig).clientId);
    params.insert("Username", m_userId);
    params.insert("ConfirmationCode", code);

    QJsonDocument jsonDoc = QJsonDocument::fromVariant(params);
    QByteArray payload = jsonDoc.toJson(QJsonDocument::Compact);

    qDebug() << "Confirming registration for user:" << m_username;

    QNetworkReply *reply = m_nam->post(request, payload);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        QByteArray data = reply->readAll();
        reply->deleteLater();
        qDebug() << "AWS signup reply:" << data;

        if (reply->error() == QNetworkReply::ProtocolInvalidOperationError) {
            QJsonParseError error;
            QVariantMap result = QJsonDocument::fromJson(data, &error).toVariant().toMap();
            if (result.value("__type").toString() == "com.amazonaws.cognito.identity.idp.model#CodeMismatchException") {
                emit confirmationResult(LoginErrorInvalidCode);
                return;
            } else if (result.value("__type").toString() == "com.amazonaws.cognito.identity.idp.model#AliasExistsException") {
                emit confirmationResult(LoginErrorUserExists);
                return;
            }
            emit confirmationResult(LoginErrorUnknownError);
            return;
        }

        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "Error confirming registration:" << reply->error() << reply->errorString();
            emit confirmationResult(LoginErrorUnknownError);
            return;
        }

        m_confirmationPending = false;
        emit confirmationPendingChanged();
        emit confirmationResult(LoginErrorNoError);
        login(m_username, m_password);
        fetchDevices();
    });
}

void AWSClient::forgotPassword(const QString &username)
{
    QString host = QString("cognito-idp.%1.amazonaws.com").arg(m_configs.value(m_usedConfig).region);
    QUrl url(QString("https://%1/").arg(host));

    QUrlQuery query;
    query.addQueryItem("Action", "ForgotPassword");
    query.addQueryItem("Version", "2016-04-18");
    url.setQuery(query);

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-amz-json-1.0");
    request.setRawHeader("Host", host.toUtf8());
    request.setRawHeader("X-Amz-Target", "AWSCognitoIdentityProviderService.ForgotPassword");

    QVariantMap params;
    params.insert("ClientId", m_configs.value(m_usedConfig).clientId);
    params.insert("Username", username);

    QJsonDocument jsonDoc = QJsonDocument::fromVariant(params);
    QByteArray payload = jsonDoc.toJson(QJsonDocument::Compact);

    qDebug() << "Forgot password for user:" << username << payload;

    QNetworkReply *reply = m_nam->post(request, payload);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        QByteArray data = reply->readAll();
        reply->deleteLater();

        if (reply->error() == QNetworkReply::ProtocolInvalidOperationError) {
            QJsonDocument jsonDoc = QJsonDocument::fromJson(data);
            if (jsonDoc.toVariant().toMap().value("__type").toString() == "com.amazonaws.cognito.identity.idp.model#LimitExceededException") {
                emit forgotPasswordResult(LoginErrorLimitExceeded);
                return;
            }
        }

        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "Error calling ForgotPassword:" << reply->error() << reply->errorString() << data;
            emit forgotPasswordResult(LoginErrorUnknownError);
            return;
        }

        qDebug() << "AWS forgotPassword success:" << data;
        emit forgotPasswordResult(LoginErrorNoError);

    });
}

void AWSClient::confirmForgotPassword(const QString &username, const QString &code, const QString &newPassword)
{
    QString host = QString("cognito-idp.%1.amazonaws.com").arg(m_configs.value(m_usedConfig).region);
    QUrl url(QString("https://%1/").arg(host));

    QUrlQuery query;
    query.addQueryItem("Action", "ConfirmForgotPassword");
    query.addQueryItem("Version", "2016-04-18");
    url.setQuery(query);

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-amz-json-1.0");
    request.setRawHeader("Host", host.toUtf8());
    request.setRawHeader("X-Amz-Target", "AWSCognitoIdentityProviderService.ConfirmForgotPassword");

    QVariantMap params;
    params.insert("ClientId", m_configs.value(m_usedConfig).clientId);
    params.insert("ConfirmationCode", code);
    params.insert("Username", username);
    params.insert("Password", newPassword);

    QJsonDocument jsonDoc = QJsonDocument::fromVariant(params);
    QByteArray payload = jsonDoc.toJson(QJsonDocument::Compact);

    qDebug() << "ConfirmForgotPassword for user:" << username << payload;

    QNetworkReply *reply = m_nam->post(request, payload);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        QByteArray data = reply->readAll();
        reply->deleteLater();

        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "Error calling ConfirmForgotPassword:" << reply->error() << reply->errorString() << data;
            emit confirmForgotPasswordResult(LoginErrorUnknownError);
            return;
        }

        qDebug() << "AWS ConfirmForgotPassword success:" << data;
        emit confirmForgotPasswordResult(LoginErrorNoError);

    });
}

void AWSClient::deleteAccount()
{
    if (!isLoggedIn()) {
        qWarning() << "Not logged in at AWS. Can't delete account";
        return;
    }
    if (tokensExpired()) {
        qDebug() << "Cannot unpair device. Need to refresh our tokens";
        refreshAccessToken();
        QueuedCall::enqueue(m_callQueue, QueuedCall("deleteAccount"));
        return;
    }
    qDebug() << "Deleting account";

    QUrl url(QString("https://%1/users/profiles/%2").arg(m_configs.value(m_usedConfig).apiEndpoint).arg(m_userId));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("x-api-idToken", m_idToken);

    qDebug() << "DELETE" << url.toString();
    qDebug() << "HEADERS:";
    foreach (const QByteArray &hdr, request.rawHeaderList()) {
        qDebug() << hdr << ":" << request.rawHeader(hdr);
    }

    QNetworkReply *reply = m_nam->deleteResource(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        QByteArray data = reply->readAll();
        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "Error deleting cloud user account:" << reply->error() << reply->errorString() << qUtf8Printable(data);
            emit deleteAccountResult(LoginErrorUnknownError);
            return;
        }
        QJsonParseError error;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(data, &error);
        if (error.error != QJsonParseError::NoError) {
            qWarning() << "Failed to parse JSON from server" << error.errorString() << qUtf8Printable(data);
            emit deleteAccountResult(LoginErrorUnknownError);
            return;
        }
        emit deleteAccountResult(LoginErrorNoError);
        logout();
        qDebug() << "Account deleted" << data;
    });
}

void AWSClient::unpairDevice(const QString &boxId)
{
    if (!isLoggedIn()) {
        qWarning() << "Not logged in at AWS. Can't unpair device";
        return;
    }
    if (tokensExpired()) {
        qDebug() << "Cannot unpair device. Need to refresh our tokens";
        refreshAccessToken();
        QueuedCall::enqueue(m_callQueue, QueuedCall("unpairDevice", boxId));
        return;
    }
    qDebug() << "unpairing device";
    QUrl url(QString("https://%1/users/devices/%2").arg(m_configs.value(m_usedConfig).apiEndpoint).arg(boxId));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("x-api-idToken", m_idToken);

    m_devices->setBusy(true);
    QNetworkReply *reply = m_nam->deleteResource(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply, boxId]() {
        reply->deleteLater();
        m_devices->setBusy(false);
        QByteArray data = reply->readAll();
        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "Error unpairing cloud device:" << reply->error() << reply->errorString() << qUtf8Printable(data);
            return;
        }
        QJsonParseError error;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(data, &error);
        if (error.error != QJsonParseError::NoError) {
            qWarning() << "Failed to parse JSON from server" << error.errorString() << qUtf8Printable(data);
            return;
        }
        qDebug() << "Device unpaired" << data;
        m_devices->remove(boxId);

    });
}

void AWSClient::getId()
{
    QString host = QString("cognito-identity.%1.amazonaws.com").arg(m_configs.value(m_usedConfig).region);
    QUrl url(QString("https://%1/").arg(host));

    QUrlQuery query;
    query.addQueryItem("Action", "GetId");
    query.addQueryItem("Version", "2016-06-30");
    url.setQuery(query);

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-amz-json-1.0");
    request.setRawHeader("Host", host.toUtf8());
    request.setRawHeader("X-Amz-Target", "AWSCognitoIdentityService.GetId");

    QVariantMap logins;
    logins.insert(QString("cognito-idp.%1.amazonaws.com/%2").arg(m_configs.value(m_usedConfig).region).arg(m_configs.value(m_usedConfig).poolId).toUtf8(), m_idToken);

    QVariantMap params;
    params.insert("IdentityPoolId", m_configs.value(m_usedConfig).identityPoolId.toUtf8());
    params.insert("Logins", logins);

    QJsonDocument jsonDoc = QJsonDocument::fromVariant(params);
    QByteArray payload = jsonDoc.toJson(QJsonDocument::Compact);

//    qDebug() << "Posting:" << request.url().toString();
//    qDebug() << "Payload:" << payload;
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

        qDebug() << "Received cognito identity id" << m_identityId;// << qUtf8Printable(data);
        getCredentialsForIdentity(m_identityId);

    });
}

void AWSClient::registerPushNotificationEndpoint(const QString &registrationId, const QString &deviceDisplayName, const QString mobileDeviceId)
{
    if (!isLoggedIn()) {
        qWarning() << "Not logged in at AWS. Can't register push endpoint";
        return;
    }
    if (tokensExpired()) {
        qDebug() << "Cannot register push endpoint. Need to refresh our tokens";
        QueuedCall::enqueue(m_callQueue, QueuedCall("registerPushNotificationEndpoint", registrationId, deviceDisplayName, mobileDeviceId));
        refreshAccessToken();
        return;
    }

    QUrl url(QString("https://%1/notifications/endpoints/%2").arg(m_configs.value(m_usedConfig).apiEndpoint).arg(m_userId));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("x-api-idToken", m_idToken);


    QVariantMap payload;
    payload.insert("registrationId", registrationId);
    payload.insert("channel", m_configs.value(m_usedConfig).pushNotificationSystem);
    payload.insert("mobileDeviceDisplayName", deviceDisplayName);
    payload.insert("mobileDeviceUuid", mobileDeviceId);
    QJsonDocument jsonDoc = QJsonDocument::fromVariant(payload);

    qDebug() << "Registering push notification endpoint";
//    qDebug() << "POST" << url.toString();
//    qDebug() << "HEADERS:";
//    foreach (const QByteArray &hdr, request.rawHeaderList()) {
//        qDebug() << hdr << ":" << request.rawHeader(hdr);
//    }
//    qDebug() << "Payload:" << qUtf8Printable(jsonDoc.toJson(QJsonDocument::Compact));

    QNetworkReply *reply = m_nam->post(request, jsonDoc.toJson(QJsonDocument::Compact));
    connect(reply, &QNetworkReply::finished, this, [reply]() {
        reply->deleteLater();
        QByteArray data = reply->readAll();
        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "Error registering push notification endpoint:" << reply->error() << reply->errorString() << qUtf8Printable(data);
            return;
        }
        qDebug() << "Push notification endpoint registered" << data;
    });

}

QByteArray AWSClient::idToken() const
{
    return m_idToken;
}

QString AWSClient::cognitoIdentityId() const
{
    return m_identityId;
}

void AWSClient::fetchCertificate(const QString &uuid, std::function<void(const QByteArray &, const QByteArray &, const QByteArray &, const QByteArray &, const QString &)> callback)
{
    QString fixedUuid = uuid;
    fixedUuid.remove(QRegExp("[{}]"));
    QNetworkRequest request(m_configs.value(m_usedConfig).certificateEndpoint);
    request.setRawHeader("X-api-key", m_configs.value(m_usedConfig).certificateApiKey.toUtf8());
    request.setRawHeader("X-api-vendorId", m_configs.value(m_usedConfig).certificateVendorId.toUtf8());
    request.setRawHeader("X-api-deviceId", fixedUuid.toUtf8());
    request.setRawHeader("X-api-serialId", "69696969");
    QNetworkReply *reply = m_nam->get(request);
    qDebug() << "Fetching certificate for vendor:" << m_configs.value(m_usedConfig).certificateVendorId << "device id:" << fixedUuid;
    connect(reply, &QNetworkReply::finished, this, [this, reply, callback]() {
        reply->deleteLater();
        QByteArray data = reply->readAll();
        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "Error deploying certificate" << data;
            return;
        }
        QJsonParseError error;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(data, &error);
        if (error.error != QJsonParseError::NoError) {
            qWarning() << "Error parsing certificate json" << data;
            return;
        }

        QByteArray certificate = jsonDoc.toVariant().toMap().value("certificatePem").toByteArray();
        QByteArray publicKey = jsonDoc.toVariant().toMap().value("keyPair").toMap().value("PublicKey").toByteArray();
        QByteArray privateKey = jsonDoc.toVariant().toMap().value("keyPair").toMap().value("PrivateKey").toByteArray();
        qDebug() << "Certificate received" << certificate;
        qDebug() << "Public key" << publicKey;
        qDebug() << "Private key" << privateKey;
        callback(rootCA, certificate, publicKey, privateKey, m_configs.value(m_usedConfig).mqttEndpoint);
    });

}

QStringList AWSClient::availableConfigs() const
{
    return m_configs.keys();
}

QString AWSClient::config() const
{
    return m_usedConfig;
}

void AWSClient::setConfig(const QString &config)
{
    if (m_usedConfig != config) {
        if (!m_configs.contains(config)) {
            qWarning() << "AWS: Config" << config << "not known. Not switching AWS config";
            return;
        }
        qDebug() << "Setting AWS configuration to" << config;
        m_usedConfig = config;
        emit configChanged();
    }
}

void AWSClient::getCredentialsForIdentity(const QString &identityId)
{
    QString host = QString("cognito-identity.%1.amazonaws.com").arg(m_configs.value(m_usedConfig).region);
    QUrl url(QString("https://%1/").arg(host));

    QUrlQuery query;
    query.addQueryItem("Action", "GetCredentialsForIdentity");
    query.addQueryItem("Version", "2016-06-30");
    url.setQuery(query);

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-amz-json-1.0");
    request.setRawHeader("Host", host.toUtf8());
    request.setRawHeader("X-Amz-Target", "AWSCognitoIdentityService.GetCredentialsForIdentity");

    QVariantMap logins;
    logins.insert(QString("cognito-idp.eu-west-1.amazonaws.com/%1").arg(m_configs.value(m_usedConfig).poolId), m_idToken);

    QVariantMap params;
    params.insert("IdentityId", identityId);
    params.insert("Logins", logins);

    QJsonDocument jsonDoc = QJsonDocument::fromVariant(params);
    QByteArray payload = jsonDoc.toJson(QJsonDocument::Compact);

//    qDebug() << "Calling GetCredentialsForIdentity:" <<  request.url();
//    qDebug() << "Headers:";
//    foreach (const QByteArray &headerName, request.rawHeaderList()) {
//        qDebug() << headerName << ":" << request.rawHeader(headerName);
//    }
//    qDebug() << "Payload:" << qUtf8Printable(payload);

    QNetworkReply *reply = m_nam->post(request, payload);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "Error calling GetCredentialsForIdentity" << reply->errorString();
            emit loginResult(LoginErrorUnknownError);
            return;
        }
        QByteArray data = reply->readAll();
        QJsonParseError error;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(data, &error);
        if (error.error != QJsonParseError::NoError) {
            qWarning() << "Error parsing JSON reply from GetCredentialsForIdentity" << error.errorString();
            emit loginResult(LoginErrorUnknownError);
            return;
        }
        QVariantMap credentialsMap = jsonDoc.toVariant().toMap().value("Credentials").toMap();

        m_accessKeyId = credentialsMap.value("AccessKeyId").toByteArray();
        m_secretKey = credentialsMap.value("SecretKey").toByteArray();
        m_sessionToken = credentialsMap.value("SessionToken").toByteArray();
        m_sessionTokenExpiry = QDateTime::fromSecsSinceEpoch(credentialsMap.value("Expiration").toLongLong());
        qDebug() << "AWS Credentials for Identity received.";// << data;

        qDebug() << "AWS login successful. Userid:" << m_userId;


        QSettings settings;
        qDebug() << "settings has:" << settings.childGroups();

        bool newLogin = !settings.childGroups().contains("cloud");

        settings.remove("cloud");
        settings.beginGroup("cloud");
        settings.setValue("username", m_username);
        settings.setValue("userId", m_userId);
        settings.setValue("password", m_password);
        settings.setValue("accessToken", m_accessToken);
        settings.setValue("accessTokenExpiry", m_accessTokenExpiry);
        settings.setValue("identityId", m_identityId);
        settings.setValue("idToken", m_idToken);
        settings.setValue("refreshToken", m_refreshToken);
        settings.setValue("accessKeyId", m_accessKeyId);
        settings.setValue("secretKey", m_secretKey);
        settings.setValue("sessionToken", m_sessionToken);
        settings.setValue("sessionTokenExpiry", m_sessionTokenExpiry);

        emit loginResult(LoginErrorNoError);

        if (newLogin) {
            qDebug() << "new login!";
            emit isLoggedInChanged();
        }

        while (!m_callQueue.isEmpty()) {
            QueuedCall qc = m_callQueue.takeFirst();
//            qDebug() << "Calling from queue:" << qc.method;
            if (qc.method == "fetchDevices") {
                fetchDevices();
            } else if (qc.method == "postToMQTT") {
                postToMQTT(qc.arg1, qc.arg2, qc.callback);
            } else if (qc.method == "deleteAccount") {
                deleteAccount();
            } else if (qc.method == "registerPushNotificationEndpoint") {
                registerPushNotificationEndpoint(qc.arg1, qc.arg2, qc.arg3);
            } else if (qc.method == "unpairDevice") {
                unpairDevice(qc.arg1);
            }
        }
    });
}

bool AWSClient::tokensExpired() const
{
    return (m_accessTokenExpiry.addSecs(-10) < QDateTime::currentDateTime()) || (m_sessionTokenExpiry.addSecs(-10) < QDateTime::currentDateTime());
}

bool AWSClient::postToMQTT(const QString &boxId, const QString &timestamp, std::function<void(bool)> callback)
{
    if (!isLoggedIn()) {
        qWarning() << "Cannot post to MQTT. Not logged in to AWS";
        return false;
    }
    if (tokensExpired()) {
        qDebug() << "Cannot post to MQTT. Need to refresh the tokens first";
        refreshAccessToken();
        QueuedCall::enqueue(m_callQueue, QueuedCall("postToMQTT", boxId, timestamp, callback));
        return true; // So far it looks we're doing ok... let's return true
    }    
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
    params.insert("timestamp", timestamp);
    QByteArray payload = QJsonDocument::fromVariant(params).toJson(QJsonDocument::Compact);


    QNetworkRequest request("https://" + m_configs.value(m_usedConfig).mqttEndpoint + path);
    request.setRawHeader("content-type", "application/json");
    request.setRawHeader("host", m_configs.value(m_usedConfig).mqttEndpoint.toUtf8());

    SigV4Utils::signRequest(QNetworkAccessManager::PostOperation, request, m_configs.value(m_usedConfig).region, "iotdata", m_accessKeyId, m_secretKey, m_sessionToken, payload);

    // Workaround MQTT broker url weirdness as described above
    request.setUrl("https://" + m_configs.value(m_usedConfig).mqttEndpoint + path1);

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
        QueuedCall::enqueue(m_callQueue, QueuedCall("fetchDevices"));
        return;
    }
//    qDebug() << "Fetching cloud devices";
    QUrl url(QString("https://%1/users/devices").arg(m_configs.value(m_usedConfig).apiEndpoint));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("x-api-idToken", m_idToken);

    m_devices->setBusy(true);
    QNetworkReply *reply = m_nam->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        m_devices->setBusy(false);
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
        QList<QUuid> actualDevices;
        foreach (const QVariant &entry, jsonDoc.toVariant().toMap().value("devices").toList()) {
            QString deviceId = entry.toMap().value("deviceId").toString();
            QString name = entry.toMap().value("name").toString();
            bool online = entry.toMap().value("online").toBool();
//            qDebug() << "Have cloud device:" << deviceId << name << "online:" << online;

            AWSDevice *d = m_devices->getDevice(deviceId);
            if (!d) {
                d = new AWSDevice(deviceId, name);
                m_devices->insert(d);
            }
            d->setOnline(online);
            actualDevices.append(d->id());
        }

        // Clean up the model
        QStringList devicesToRemove;
        for (int i = 0; i < m_devices->rowCount(); i++) {
            if (!actualDevices.contains(m_devices->get(i)->id())) {
                devicesToRemove.append(m_devices->get(i)->id());
            }
        }
        while (!devicesToRemove.isEmpty()) {
            m_devices->remove(devicesToRemove.takeFirst());
        }

        emit devicesFetched();

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
    QString host = QString("cognito-idp.%1.amazonaws.com").arg(m_configs.value(m_usedConfig).region);
    QUrl url(QString("https://%1/").arg(host));

    QUrlQuery query;
    query.addQueryItem("Action", "InitiateAuth");
    query.addQueryItem("Version", "2016-04-18");
    url.setQuery(query);

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-amz-json-1.0");
    request.setRawHeader("Host", host.toUtf8());
    request.setRawHeader("X-Amz-Target", "AWSCognitoIdentityProviderService.InitiateAuth");

    QVariantMap params;
    params.insert("AuthFlow", "REFRESH_TOKEN_AUTH");
    params.insert("ClientId", m_configs.value(m_usedConfig).clientId);

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


AWSDevices::AWSDevices(QObject *parent):
    QAbstractListModel(parent)
{

}

int AWSDevices::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return  m_list.count();
}

QVariant AWSDevices::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleName:
        return m_list.at(index.row())->name();
    case RoleId:
        return m_list.at(index.row())->id();
    case RoleOnline:
        return m_list.at(index.row())->online();
    }
    return QVariant();
}

QHash<int, QByteArray> AWSDevices::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleName, "name");
    roles.insert(RoleId, "id");
    roles.insert(RoleOnline, "online");
    return roles;
}

bool AWSDevices::busy() const
{
    return m_busy;
}

void AWSDevices::setBusy(bool busy)
{
    if (m_busy != busy) {
        m_busy = busy;
        emit busyChanged();
    }
}

AWSDevice *AWSDevices::getDevice(const QString &uuid) const
{
    for (int i = 0; i < m_list.count(); i++) {
        if (QUuid(m_list.at(i)->id()) == QUuid(uuid)) {
            return m_list.at(i);
        }
    }
    return nullptr;
}

AWSDevice *AWSDevices::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

void AWSDevices::insert(AWSDevice *device)
{
    device->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(device);
    endInsertRows();
    emit countChanged();
}

void AWSDevices::remove(const QString &uuid)
{
    int idx = -1;
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->id() == uuid) {
            idx = i;
            break;
        }
    }
    if (idx == -1) {
        qWarning() << "Cannot remove AWS with id" << uuid << "as there is no such device";
        return;
    }
    beginRemoveRows(QModelIndex(), idx, idx);
    m_list.takeAt(idx)->deleteLater();
    endRemoveRows();
    emit countChanged();
}

void AWSDevices::clear()
{
    beginResetModel();
    while (m_list.count() > 0) {
        m_list.takeFirst()->deleteLater();
    }
    endResetModel();
    emit countChanged();
}

AWSDevice::AWSDevice(const QString &id, const QString &name, bool online, QObject *parent):
    QObject (parent),
    m_id(id),
    m_name(name),
    m_online(online)
{

}

QString AWSDevice::id() const
{
    return m_id;
}

QString AWSDevice::name() const
{
    return m_name;
}

bool AWSDevice::online() const
{
    return m_online;
}

void AWSDevice::setOnline(bool online)
{
    if (m_online != online) {
        m_online = online;
        emit onlineChanged();
    }
}
