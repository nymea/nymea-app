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
    challengeResponses.insert("PASSWORD_CLAIM_SIGNATURE", QByteArray(bytes_M, len_M).toHex());
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

QByteArray AWSClient::createClaim(const QByteArray &secretBlock, const QByteArray &srpB, const QByteArray &salt)
{
//    byte[] authSecretBlock = System.Convert.FromBase64String(secretBlock);
    QByteArray authSecretBlock = QByteArray::fromBase64(secretBlock);

//	BigInteger B = new BigInteger(srp_b, 16);
//    if (B.Mod(AuthenticationHelper.N).Equals(BigInteger.Zero))
//	{
//		throw new Exception("B cannot be zero");
//	}
    bool ok;
    qlonglong b = srpB.toLongLong(&ok, 16);
    if (!ok) {
        qWarning() << "Error converting srpB to number";
        return QByteArray();
    }

//	BigInteger salt = new BigInteger(saltString, 16);
    qlonglong saltNumber = salt.toLongLong(&ok, 16);
    if (!ok) {
        qWarning() << "Error converting salt to number";
        return QByteArray();
    }

    // We need to generate the key to hash the response based on our A and what AWS sent back
    byte[] key = getPasswordAuthenticationKey(username, password, poolName, TupleAa, B, salt);

    // HMAC our data with key (HKDF(S)) (the shared secret)
    byte[] hmac;
    try
    {
        HMAC mac = HMAC.Create("HMACSHA256");
        mac.Key = key;

        //bytes bytes bytes....
        byte[] poolNameByte = Encoding.UTF8.GetBytes(poolName);
        byte[] name = Encoding.UTF8.GetBytes(username);
        //secretBlock here
        byte[] timeByte = Encoding.UTF8.GetBytes(formattedTimestamp);
        byte[] content = new byte[poolNameByte.Length + name.Length + authSecretBlock.Length + timeByte.Length];

        Buffer.BlockCopy(poolNameByte, 0, content, 0, poolNameByte.Length);
        Buffer.BlockCopy(name, 0, content, poolNameByte.Length, name.Length);
        Buffer.BlockCopy(authSecretBlock, 0, content, poolNameByte.Length + name.Length, authSecretBlock.Length);
        Buffer.BlockCopy(timeByte, 0, content, poolNameByte.Length + name.Length + authSecretBlock.Length, timeByte.Length);

        hmac = mac.ComputeHash(content);
    }
    catch (Exception e)
    {
        throw new Exception("Exception in authentication", e);
    }

    return hmac;
}

QByteArray AWSClient::getPasswordAuthenticationKey(const QByteArray &username, const QByteArray &password)
{

}

