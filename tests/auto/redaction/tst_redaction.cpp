// SPDX-License-Identifier: LGPL-3.0-or-later

#include "jsonrpc/jsonrpcclient.h"

#include <QTest>

namespace {
const QByteArray kSentinelToken = QByteArray("SENTINEL-ONE-TIME-OR-REGULAR-TOKEN-VALUE-DO-NOT-LEAK");
}

class RedactionTest : public QObject
{
    Q_OBJECT

private slots:
    void redactsTopLevelToken();
    void redactsParamsToken();
    void redactsBothLevelsAtOnce();
    void leavesNonTokenFieldsIntact();
    void isNoOpWithoutTokenFields();

    void redactedJsonNeverContainsSentinel_data();
    void redactedJsonNeverContainsSentinel();

    void secretBearingMethods_data();
    void secretBearingMethods();
};

void RedactionTest::redactsTopLevelToken()
{
    QVariantMap data;
    data.insert("token", kSentinelToken);
    QVariantMap redacted = JsonRpcClient::redactSensitiveFields(data);
    QVERIFY(redacted.value("token").toByteArray() != kSentinelToken);
}

void RedactionTest::redactsParamsToken()
{
    QVariantMap params;
    params.insert("token", kSentinelToken);
    params.insert("username", "alice");
    QVariantMap data;
    data.insert("params", params);

    QVariantMap redacted = JsonRpcClient::redactSensitiveFields(data);
    QVariantMap redactedParams = redacted.value("params").toMap();
    QVERIFY(redactedParams.value("token").toByteArray() != kSentinelToken);
    QCOMPARE(redactedParams.value("username").toString(), QStringLiteral("alice"));
}

void RedactionTest::redactsBothLevelsAtOnce()
{
    QByteArray bearerToken = kSentinelToken + "-BEARER";
    QByteArray oneTimeToken = kSentinelToken + "-ONETIME";

    QVariantMap params;
    params.insert("token", oneTimeToken);
    QVariantMap data;
    data.insert("token", bearerToken);
    data.insert("params", params);

    QVariantMap redacted = JsonRpcClient::redactSensitiveFields(data);
    QVERIFY(redacted.value("token").toByteArray() != bearerToken);
    QVERIFY(redacted.value("params").toMap().value("token").toByteArray() != oneTimeToken);
}

void RedactionTest::leavesNonTokenFieldsIntact()
{
    QVariantMap params;
    params.insert("username", "alice");
    params.insert("deviceName", "nymea-app (Pixel)");
    QVariantMap data;
    data.insert("id", 42);
    data.insert("method", "Users.CreateInvitation");
    data.insert("params", params);

    QVariantMap redacted = JsonRpcClient::redactSensitiveFields(data);
    QCOMPARE(redacted.value("id").toInt(), 42);
    QCOMPARE(redacted.value("method").toString(), QStringLiteral("Users.CreateInvitation"));
    QCOMPARE(redacted.value("params").toMap().value("username").toString(), QStringLiteral("alice"));
    QCOMPARE(redacted.value("params").toMap().value("deviceName").toString(), QStringLiteral("nymea-app (Pixel)"));
}

void RedactionTest::isNoOpWithoutTokenFields()
{
    QVariantMap data;
    data.insert("notification", "Users.InvitationAdded");
    QVariantMap invitation;
    invitation.insert("id", "{11111111-1111-1111-1111-111111111111}");
    invitation.insert("username", "alice");
    QVariantMap params;
    params.insert("invitation", invitation);
    data.insert("params", params);

    QVariantMap redacted = JsonRpcClient::redactSensitiveFields(data);
    QCOMPARE(redacted, data);
}

void RedactionTest::redactedJsonNeverContainsSentinel_data()
{
    QTest::addColumn<QVariantMap>("data");

    QVariantMap request;
    request.insert("id", 1);
    request.insert("method", "JSONRPC.AuthenticateWithToken");
    QVariantMap requestParams;
    requestParams.insert("token", kSentinelToken);
    requestParams.insert("deviceName", "nymea-app");
    request.insert("params", requestParams);
    QTest::newRow("outgoing AuthenticateWithToken request") << request;

    QVariantMap response;
    response.insert("id", 1);
    response.insert("status", "success");
    QVariantMap responseParams;
    responseParams.insert("success", true);
    responseParams.insert("token", kSentinelToken);
    responseParams.insert("username", "alice");
    response.insert("params", responseParams);
    QTest::newRow("AuthenticateWithToken success reply") << response;

    QVariantMap sentRequestEnvelope;
    sentRequestEnvelope.insert("id", 2);
    sentRequestEnvelope.insert("method", "JSONRPC.Hello");
    sentRequestEnvelope.insert("token", kSentinelToken);
    QTest::newRow("outgoing envelope with bearer token") << sentRequestEnvelope;
}

void RedactionTest::redactedJsonNeverContainsSentinel()
{
    QFETCH(QVariantMap, data);
    QByteArray json = JsonRpcClient::redactedJson(data);
    QVERIFY2(!json.contains(kSentinelToken), "Sentinel token leaked into redacted JSON log output");
}

void RedactionTest::secretBearingMethods_data()
{
    QTest::addColumn<QString>("method");
    QTest::addColumn<bool>("secretBearing");

    QTest::newRow("Authenticate") << QStringLiteral("JSONRPC.Authenticate") << true;
    QTest::newRow("AuthenticateWithToken") << QStringLiteral("JSONRPC.AuthenticateWithToken") << true;
    QTest::newRow("RequestPushButtonAuth") << QStringLiteral("JSONRPC.RequestPushButtonAuth") << true;
    QTest::newRow("CreateInvitation") << QStringLiteral("Users.CreateInvitation") << true;
    QTest::newRow("GetInvitations") << QStringLiteral("Users.GetInvitations") << false;
    QTest::newRow("RemoveInvitation") << QStringLiteral("Users.RemoveInvitation") << false;
    QTest::newRow("Hello") << QStringLiteral("JSONRPC.Hello") << false;
    QTest::newRow("GetTokens") << QStringLiteral("Users.GetTokens") << false;
}

void RedactionTest::secretBearingMethods()
{
    QFETCH(QString, method);
    QFETCH(bool, secretBearing);
    QCOMPARE(JsonRpcClient::isSecretBearingMethod(method), secretBearing);
}

QTEST_GUILESS_MAIN(RedactionTest)

#include "tst_redaction.moc"
