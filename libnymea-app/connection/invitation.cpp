// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "invitation.h"

#include <QRegularExpression>
#include <QSet>
#include <QUrlQuery>

namespace {
const QSet<QString> kAllowedCandidateSchemes = {
    QStringLiteral("nymea"),
    QStringLiteral("nymeas"),
    QStringLiteral("wss"),
    QStringLiteral("tunnels")
};
}

Invitation::Invitation()
{
}

Invitation::Invitation(const QUuid &uuid, const QString &name, const QByteArray &token, const QList<QUrl> &candidates):
    m_uuid(uuid),
    m_name(name),
    m_token(token),
    m_candidates(candidates)
{
}

bool Invitation::isCanonicalToken(const QByteArray &token)
{
    if (token.length() != 44) {
        return false;
    }
    if (token.count('=') != 1 || !token.endsWith('=')) {
        return false;
    }

    QByteArray decoded = QByteArray::fromBase64(token, QByteArray::Base64Encoding | QByteArray::AbortOnBase64DecodingErrors);
    if (decoded.length() != 32) {
        return false;
    }

    // Reject non-canonical encodings a lenient decoder might still accept (e.g. non-zero
    // padding bits) by requiring an exact re-encode round trip.
    if (decoded.toBase64() != token) {
        return false;
    }

    return true;
}

bool Invitation::validateAndNormalizeCandidate(QUrl &url, const QUuid &invitationUuid)
{
    if (!url.isValid() || url.isRelative() || url.isEmpty()) {
        return false;
    }

    QString scheme = url.scheme().toLower();
    if (!kAllowedCandidateSchemes.contains(scheme)) {
        return false;
    }
    if (url.host().isEmpty()) {
        return false;
    }
    if (url.port(-1) == -1) {
        return false;
    }
    if (!url.userInfo().isEmpty()) {
        return false;
    }
    if (url.hasFragment()) {
        return false;
    }
    if (!url.path().isEmpty()) {
        return false;
    }

    QUuid tunnelUuid;
    if (scheme == QStringLiteral("tunnels")) {
        QUrlQuery candidateQuery(url);
        const QList<QPair<QString, QString>> items = candidateQuery.queryItems(QUrl::FullyDecoded);
        if (items.size() != 1 || items.first().first != QStringLiteral("uuid")) {
            return false;
        }
        tunnelUuid = QUuid(items.first().second);
        if (tunnelUuid.isNull() || tunnelUuid != invitationUuid) {
            return false;
        }
    } else if (url.hasQuery()) {
        return false;
    }

    QUrl normalized;
    normalized.setScheme(scheme);
    normalized.setHost(url.host().toLower());
    normalized.setPort(url.port());
    if (scheme == QStringLiteral("tunnels")) {
        QUrlQuery normalizedQuery;
        normalizedQuery.addQueryItem(QStringLiteral("uuid"), tunnelUuid.toString());
        normalized.setQuery(normalizedQuery);
    }
    url = normalized;
    return true;
}

Invitation Invitation::fromUrl(const QUrl &url, const QString &configuredScheme, const QString &configuredAppLinkDomain)
{
    Invitation result;
    result.m_error = ParseError::InvalidScheme;

    if (url.toEncoded().size() > MaxEncodedUrlBytes) {
        result.m_error = ParseError::OversizedUrl;
        return result;
    }

    QString queryString;
    bool matchedShape = false;

    if (!configuredScheme.isEmpty() && url.scheme().compare(configuredScheme, Qt::CaseInsensitive) == 0) {
        if (url.host().compare(QStringLiteral("invite"), Qt::CaseInsensitive) != 0
                || !url.path().isEmpty() || url.hasFragment() || !url.userInfo().isEmpty()) {
            return result;
        }
        matchedShape = true;
        queryString = url.query(QUrl::FullyEncoded);
    } else if (url.scheme().compare(QStringLiteral("https"), Qt::CaseInsensitive) == 0) {
        // Structurally ready for the future App-/Universal-Link wrapper, but v1 ships
        // with no configured domain, so this branch is always rejected in practice.
        if (configuredAppLinkDomain.isEmpty()
                || url.host().compare(configuredAppLinkDomain, Qt::CaseInsensitive) != 0
                || url.path() != QStringLiteral("/invite") || !url.userInfo().isEmpty()) {
            return result;
        }
        matchedShape = true;
        queryString = url.fragment(QUrl::FullyEncoded);
    }

    if (!matchedShape) {
        return result;
    }

    QUrlQuery query(queryString);
    QMap<QString, QStringList> byKey;
    const QList<QPair<QString, QString>> items = query.queryItems(QUrl::FullyDecoded);
    for (const auto &item : items) {
        byKey[item.first].append(item.second);
    }

    if (byKey.value(QStringLiteral("v")).size() == 0
            || byKey.value(QStringLiteral("uuid")).size() == 0
            || byKey.value(QStringLiteral("t")).size() == 0) {
        result.m_error = ParseError::MissingRequiredField;
        return result;
    }
    if (byKey.value(QStringLiteral("v")).size() > 1
            || byKey.value(QStringLiteral("uuid")).size() > 1
            || byKey.value(QStringLiteral("t")).size() > 1
            || byKey.value(QStringLiteral("name")).size() > 1) {
        result.m_error = ParseError::DuplicateScalarKey;
        return result;
    }

    if (byKey.value(QStringLiteral("v")).first() != QStringLiteral("1")) {
        result.m_error = ParseError::InvalidVersion;
        return result;
    }

    static const QRegularExpression uuidPattern(QStringLiteral(
        "^\\{[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\\}$"));
    const QString uuidValue = byKey.value(QStringLiteral("uuid")).first();
    if (!uuidPattern.match(uuidValue).hasMatch()) {
        result.m_error = ParseError::InvalidUuid;
        return result;
    }
    const QUuid uuid(uuidValue);
    if (uuid.isNull()) {
        result.m_error = ParseError::InvalidUuid;
        return result;
    }

    QString name;
    if (byKey.value(QStringLiteral("name")).size() == 1) {
        name = byKey.value(QStringLiteral("name")).first();
        if (name.toUtf8().size() > MaxNameBytes) {
            result.m_error = ParseError::InvalidName;
            return result;
        }
    }

    const QByteArray token = byKey.value(QStringLiteral("t")).first().toLatin1();
    if (!isCanonicalToken(token)) {
        result.m_error = ParseError::InvalidToken;
        return result;
    }

    const QStringList candidateValues = byKey.value(QStringLiteral("c"));
    if (candidateValues.isEmpty()) {
        result.m_error = ParseError::MissingRequiredField;
        return result;
    }
    if (candidateValues.size() > MaxCandidates) {
        result.m_error = ParseError::TooManyCandidates;
        return result;
    }

    QList<QUrl> validCandidates;
    QSet<QString> seenCandidateKeys;
    for (const QString &raw : candidateValues) {
        QUrl candidateUrl(raw, QUrl::StrictMode);
        if (!validateAndNormalizeCandidate(candidateUrl, uuid)) {
            continue;
        }
        const QString key = candidateUrl.toString(QUrl::FullyEncoded);
        if (seenCandidateKeys.contains(key)) {
            continue;
        }
        seenCandidateKeys.insert(key);
        validCandidates.append(candidateUrl);
    }

    if (validCandidates.isEmpty()) {
        result.m_error = ParseError::NoUsableCandidate;
        return result;
    }

    result.m_error = ParseError::NoError;
    result.m_uuid = uuid;
    result.m_name = name;
    result.m_token = token;
    result.m_candidates = validCandidates;
    return result;
}

QUrl Invitation::toUrl(const QString &scheme) const
{
    QUrl url;
    url.setScheme(scheme);
    url.setHost(QStringLiteral("invite"));

    QUrlQuery query;
    query.addQueryItem(QStringLiteral("v"), QStringLiteral("1"));
    query.addQueryItem(QStringLiteral("uuid"), m_uuid.toString());
    if (!m_name.isEmpty()) {
        query.addQueryItem(QStringLiteral("name"), m_name);
    }
    query.addQueryItem(QStringLiteral("t"), QString::fromLatin1(m_token));
    for (const QUrl &candidate : m_candidates) {
        query.addQueryItem(QStringLiteral("c"), candidate.toString());
    }
    url.setQuery(query);

    if (url.toEncoded().size() > MaxEncodedUrlBytes) {
        return QUrl();
    }
    return url;
}

bool Invitation::isValid() const
{
    return m_error == ParseError::NoError;
}

Invitation::ParseError Invitation::error() const
{
    return m_error;
}

QUuid Invitation::uuid() const
{
    return m_uuid;
}

QString Invitation::name() const
{
    return m_name;
}

QByteArray Invitation::token() const
{
    return m_token;
}

QList<QUrl> Invitation::candidates() const
{
    return m_candidates;
}
