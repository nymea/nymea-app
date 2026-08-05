// SPDX-License-Identifier: LGPL-3.0-or-later

#include "connection/invitation.h"

#include <QTest>
#include <QUrl>
#include <QUrlQuery>

namespace {
const QString kScheme = QStringLiteral("nymea");
const QUuid kUuid = QUuid(QStringLiteral("{11111111-1111-1111-1111-111111111111}"));
// 44 canonical Base64 ASCII bytes decoding to a 32-byte digest.
const QByteArray kToken = QByteArray("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=");

QString baseUrl()
{
    return QStringLiteral("nymea://invite?v=1&uuid=%7B11111111-1111-1111-1111-111111111111%7D"
                           "&t=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA%3D"
                           "&c=nymeas%3A%2F%2Fhost%3A2222");
}
}

class InvitationTest : public QObject
{
    Q_OBJECT

private slots:
    void canonicalTokenValidation_data();
    void canonicalTokenValidation();

    void parsesValidMinimalLink();
    void parsesOptionalName();
    void rejectsOversizedUrl();
    void rejectsWrongScheme();
    void rejectsDuplicateScalarKey_data();
    void rejectsDuplicateScalarKey();
    void rejectsMissingRequiredField_data();
    void rejectsMissingRequiredField();
    void rejectsMalformedUuid_data();
    void rejectsMalformedUuid();
    void rejectsOverlongName();
    void rejectsTooManyCandidates();
    void ignoresUnknownQueryParameter();

    void candidateValidation_data();
    void candidateValidation();
    void tunnelCandidateRequiresMatchingUuid();
    void deduplicatesCandidatesPreservingOrder();

    void roundTripsThroughToUrl();
    void toUrlFailsClosedWhenOverBudget();
    void toUrlOmitsNameWhenEmpty();
};

void InvitationTest::canonicalTokenValidation_data()
{
    QTest::addColumn<QByteArray>("token");
    QTest::addColumn<bool>("valid");

    QTest::newRow("canonical") << kToken << true;
    QTest::newRow("wrong-length") << QByteArray("AAAA=") << false;
    QTest::newRow("two-padding-chars") << QByteArray("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==") << false;
    QTest::newRow("no-padding") << QByteArray("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA") << false;
    QTest::newRow("invalid-base64-char") << QByteArray("!AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=") << false;
    // Non-canonical padding bits: decodes to 32 bytes via a lenient decoder, but the
    // canonical re-encode of those bytes would not reproduce this exact string.
    QTest::newRow("non-canonical-padding") << QByteArray("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB=") << false;
}

void InvitationTest::canonicalTokenValidation()
{
    QFETCH(QByteArray, token);
    QFETCH(bool, valid);
    QCOMPARE(Invitation::isCanonicalToken(token), valid);
}

void InvitationTest::parsesValidMinimalLink()
{
    Invitation invitation = Invitation::fromUrl(QUrl(baseUrl()), kScheme);
    QVERIFY(invitation.isValid());
    QCOMPARE(invitation.error(), Invitation::ParseError::NoError);
    QCOMPARE(invitation.uuid(), kUuid);
    QCOMPARE(invitation.token(), kToken);
    QVERIFY(invitation.name().isEmpty());
    QCOMPARE(invitation.candidates().size(), 1);
    QCOMPARE(invitation.candidates().first().toString(), QStringLiteral("nymeas://host:2222"));
}

void InvitationTest::parsesOptionalName()
{
    Invitation invitation = Invitation::fromUrl(QUrl(baseUrl() + "&name=Living%20Room"), kScheme);
    QVERIFY(invitation.isValid());
    QCOMPARE(invitation.name(), QStringLiteral("Living Room"));
}

void InvitationTest::rejectsOversizedUrl()
{
    QString oversized = baseUrl() + "&name=" + QString(2100, QLatin1Char('a'));
    Invitation invitation = Invitation::fromUrl(QUrl(oversized), kScheme);
    QVERIFY(!invitation.isValid());
    QCOMPARE(invitation.error(), Invitation::ParseError::OversizedUrl);
}

void InvitationTest::rejectsWrongScheme()
{
    Invitation invitation = Invitation::fromUrl(QUrl(baseUrl()), QStringLiteral("otherbrand"));
    QVERIFY(!invitation.isValid());
    QCOMPARE(invitation.error(), Invitation::ParseError::InvalidScheme);
}

void InvitationTest::rejectsDuplicateScalarKey_data()
{
    QTest::addColumn<QString>("extra");
    QTest::newRow("duplicate-v") << QStringLiteral("&v=1");
    QTest::newRow("duplicate-uuid") << QStringLiteral("&uuid=%7B22222222-2222-2222-2222-222222222222%7D");
    QTest::newRow("duplicate-t") << QStringLiteral("&t=BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB%3D");
    QTest::newRow("duplicate-name") << QStringLiteral("&name=A&name=B");
}

void InvitationTest::rejectsDuplicateScalarKey()
{
    QFETCH(QString, extra);
    Invitation invitation = Invitation::fromUrl(QUrl(baseUrl() + extra), kScheme);
    QVERIFY(!invitation.isValid());
    QCOMPARE(invitation.error(), Invitation::ParseError::DuplicateScalarKey);
}

void InvitationTest::rejectsMissingRequiredField_data()
{
    QTest::addColumn<QString>("url");
    QTest::newRow("no-v") << QStringLiteral("nymea://invite?uuid=%7B11111111-1111-1111-1111-111111111111%7D"
                                             "&t=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA%3D&c=nymeas%3A%2F%2Fhost%3A2222");
    QTest::newRow("no-uuid") << QStringLiteral("nymea://invite?v=1"
                                                "&t=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA%3D&c=nymeas%3A%2F%2Fhost%3A2222");
    QTest::newRow("no-t") << QStringLiteral("nymea://invite?v=1&uuid=%7B11111111-1111-1111-1111-111111111111%7D"
                                             "&c=nymeas%3A%2F%2Fhost%3A2222");
    QTest::newRow("no-c") << QStringLiteral("nymea://invite?v=1&uuid=%7B11111111-1111-1111-1111-111111111111%7D"
                                             "&t=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA%3D");
}

void InvitationTest::rejectsMissingRequiredField()
{
    QFETCH(QString, url);
    Invitation invitation = Invitation::fromUrl(QUrl(url), kScheme);
    QVERIFY(!invitation.isValid());
    QCOMPARE(invitation.error(), Invitation::ParseError::MissingRequiredField);
}

void InvitationTest::rejectsMalformedUuid_data()
{
    QTest::addColumn<QString>("uuidValue");
    QTest::newRow("unbraced") << QStringLiteral("11111111-1111-1111-1111-111111111111");
    QTest::newRow("not-a-uuid") << QStringLiteral("%7Bnot-a-uuid%7D");
    QTest::newRow("empty") << QStringLiteral("");
}

void InvitationTest::rejectsMalformedUuid()
{
    QFETCH(QString, uuidValue);
    QString url = QStringLiteral("nymea://invite?v=1&uuid=") + uuidValue
            + QStringLiteral("&t=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA%3D&c=nymeas%3A%2F%2Fhost%3A2222");
    Invitation invitation = Invitation::fromUrl(QUrl(url), kScheme);
    QVERIFY(!invitation.isValid());
    QCOMPARE(invitation.error(), Invitation::ParseError::InvalidUuid);
}

void InvitationTest::rejectsOverlongName()
{
    // 129 non-ASCII (2-byte UTF-8) code points => 258 bytes, well over the 128 byte cap.
    QString overlongName = QString(129, QChar(0x00e9));
    Invitation invitation = Invitation::fromUrl(QUrl(baseUrl() + "&name=" + QUrl::toPercentEncoding(overlongName)), kScheme);
    QVERIFY(!invitation.isValid());
    QCOMPARE(invitation.error(), Invitation::ParseError::InvalidName);
}

void InvitationTest::rejectsTooManyCandidates()
{
    QString url = QStringLiteral("nymea://invite?v=1&uuid=%7B11111111-1111-1111-1111-111111111111%7D"
                                  "&t=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA%3D");
    for (int i = 0; i < 9; i++) {
        url += QStringLiteral("&c=nymeas%3A%2F%2Fhost%1%3A2222").arg(i);
    }
    Invitation invitation = Invitation::fromUrl(QUrl(url), kScheme);
    QVERIFY(!invitation.isValid());
    QCOMPARE(invitation.error(), Invitation::ParseError::TooManyCandidates);
}

void InvitationTest::ignoresUnknownQueryParameter()
{
    Invitation invitation = Invitation::fromUrl(QUrl(baseUrl() + "&unknown=whatever"), kScheme);
    QVERIFY(invitation.isValid());
}

void InvitationTest::candidateValidation_data()
{
    QTest::addColumn<QString>("candidate");
    QTest::addColumn<bool>("valid");

    QTest::newRow("nymea-plain") << QStringLiteral("nymea://host:2223") << true;
    QTest::newRow("nymeas-secure") << QStringLiteral("nymeas://host:2222") << true;
    QTest::newRow("wss-secure") << QStringLiteral("wss://host:4444") << true;
    QTest::newRow("ws-plain-rejected") << QStringLiteral("ws://host:4444") << false;
    QTest::newRow("tunnel-plain-rejected") << QStringLiteral("tunnel://proxy:2213?uuid=%7B11111111-1111-1111-1111-111111111111%7D") << false;
    QTest::newRow("http-scheme-rejected") << QStringLiteral("http://host:80") << false;
    QTest::newRow("missing-port") << QStringLiteral("nymeas://host") << false;
    QTest::newRow("missing-host") << QStringLiteral("nymeas://:2222") << false;
    QTest::newRow("userinfo-rejected") << QStringLiteral("nymeas://user@host:2222") << false;
    QTest::newRow("fragment-rejected") << QStringLiteral("nymeas://host:2222#frag") << false;
    QTest::newRow("path-rejected") << QStringLiteral("nymeas://host:2222/extra") << false;
    QTest::newRow("unexpected-query-on-nymeas") << QStringLiteral("nymeas://host:2222?foo=bar") << false;
    QTest::newRow("relative-rejected") << QStringLiteral("host:2222") << false;
}

void InvitationTest::candidateValidation()
{
    QFETCH(QString, candidate);
    QFETCH(bool, valid);

    QString url = baseUrl().section(QStringLiteral("&c="), 0, 0) + "&c=" + QUrl::toPercentEncoding(candidate);
    Invitation invitation = Invitation::fromUrl(QUrl(url), kScheme);
    QCOMPARE(invitation.isValid(), valid);
    if (!valid) {
        QCOMPARE(invitation.error(), Invitation::ParseError::NoUsableCandidate);
    }
}

void InvitationTest::tunnelCandidateRequiresMatchingUuid()
{
    QString mismatched = baseUrl().section(QStringLiteral("&c="), 0, 0)
            + "&c=" + QUrl::toPercentEncoding(QStringLiteral("tunnels://proxy:2213?uuid=%7B22222222-2222-2222-2222-222222222222%7D"));
    Invitation invalid = Invitation::fromUrl(QUrl(mismatched), kScheme);
    QVERIFY(!invalid.isValid());
    QCOMPARE(invalid.error(), Invitation::ParseError::NoUsableCandidate);

    QString matched = baseUrl().section(QStringLiteral("&c="), 0, 0)
            + "&c=" + QUrl::toPercentEncoding(QStringLiteral("tunnels://proxy:2213?uuid=%7B11111111-1111-1111-1111-111111111111%7D"));
    Invitation valid = Invitation::fromUrl(QUrl(matched), kScheme);
    QVERIFY(valid.isValid());
    QCOMPARE(valid.candidates().size(), 1);
}

void InvitationTest::deduplicatesCandidatesPreservingOrder()
{
    QString base = baseUrl().section(QStringLiteral("&c="), 0, 0);
    QString url = base
            + "&c=" + QUrl::toPercentEncoding(QStringLiteral("wss://second:4444"))
            + "&c=" + QUrl::toPercentEncoding(QStringLiteral("nymeas://HOST:2222")) // same as first, different case
            + "&c=" + QUrl::toPercentEncoding(QStringLiteral("nymeas://host:2222"));
    Invitation invitation = Invitation::fromUrl(QUrl(url), kScheme);
    QVERIFY(invitation.isValid());
    QCOMPARE(invitation.candidates().size(), 2);
    // Encounter order in the payload, not alphabetical/priority order: "wss://second"
    // appears first, then "nymeas://host" (its later HOST-case duplicate is dropped).
    QCOMPARE(invitation.candidates().at(0).toString(), QStringLiteral("wss://second:4444"));
    QCOMPARE(invitation.candidates().at(1).toString(), QStringLiteral("nymeas://host:2222"));
}

void InvitationTest::roundTripsThroughToUrl()
{
    Invitation invitation = Invitation::fromUrl(QUrl(baseUrl() + "&name=Living%20Room"), kScheme);
    QVERIFY(invitation.isValid());

    Invitation reassembled(invitation.uuid(), invitation.name(), invitation.token(), invitation.candidates());
    QUrl url = reassembled.toUrl(kScheme);
    QVERIFY(!url.isEmpty());

    Invitation reparsed = Invitation::fromUrl(url, kScheme);
    QVERIFY(reparsed.isValid());
    QCOMPARE(reparsed.uuid(), invitation.uuid());
    QCOMPARE(reparsed.name(), invitation.name());
    QCOMPARE(reparsed.token(), invitation.token());
    QCOMPARE(reparsed.candidates(), invitation.candidates());
}

void InvitationTest::toUrlFailsClosedWhenOverBudget()
{
    // Each label is kept under the 63-byte DNS label limit (QUrl itself rejects a
    // longer single label as an invalid hostname); dot-joined repeats instead push the
    // overall encoded size over the 2048-byte budget across 8 tunnel candidates.
    QList<QUrl> candidates;
    for (int i = 0; i < 8; i++) {
        QString label = QStringLiteral("some-quite-long-proxy-hostname-part-%1").arg(i);
        QString host = QStringLiteral("%1.%1.%1.%1.example.com").arg(label);
        candidates.append(QUrl(QStringLiteral("tunnels://%1:2213?uuid=%2").arg(host, kUuid.toString())));
    }

    Invitation invitation(kUuid, QString(128, QChar(u'x')), kToken, candidates);
    QUrl url = invitation.toUrl(kScheme);
    QVERIFY(url.isEmpty());
}

void InvitationTest::toUrlOmitsNameWhenEmpty()
{
    Invitation invitation(kUuid, QString(), kToken, {QUrl(QStringLiteral("nymeas://host:2222"))});
    QUrl url = invitation.toUrl(kScheme);
    QVERIFY(!url.isEmpty());
    QVERIFY(!url.query().contains(QStringLiteral("name=")));
}

QTEST_GUILESS_MAIN(InvitationTest)

#include "tst_invitation.moc"
