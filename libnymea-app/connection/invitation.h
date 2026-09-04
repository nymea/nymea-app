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

#ifndef INVITATION_H
#define INVITATION_H

#include <QByteArray>
#include <QList>
#include <QString>
#include <QUrl>
#include <QUuid>

// Pure value type for the v1 invitation deep link
// (<scheme>://invite?v=1&uuid=<uuid>&name=<name>&t=<token>&c=<candidate>[&c=<candidate>...]).
// Holds no network/UI state and performs no I/O, so it stays independently unit-testable.
// Never put the clear token or a complete invitation URL into debug output, telemetry,
// assertions, crash breadcrumbs, or user-facing errors - treat both as secrets end to end.
class Invitation
{
public:
    enum class ParseError {
        NoError,
        OversizedUrl,
        InvalidScheme,
        MissingRequiredField,
        DuplicateScalarKey,
        InvalidVersion,
        InvalidUuid,
        InvalidName,
        InvalidToken,
        TooManyCandidates,
        NoUsableCandidate
    };

    Invitation();

    // Constructs an invitation to be assembled (admin side). candidates must already be
    // priority-ordered, deduplicated, and trimmed to fit the size budget by the caller;
    // toUrl() re-validates and normalizes them but does not reorder, dedupe, or trim.
    Invitation(const QUuid &uuid, const QString &name, const QByteArray &token, const QList<QUrl> &candidates);

    // Parses either the v1 custom-scheme form (<configuredScheme>://invite?...) or, only
    // when configuredAppLinkDomain is non-empty, the future HTTPS wrapper form
    // (https://<configuredAppLinkDomain>/invite#...). With no configured domain (the only
    // supported v1 build configuration), any https:// input is rejected. Unknown query
    // parameters are ignored, but only after the overall size/count limits are enforced.
    static Invitation fromUrl(const QUrl &url, const QString &configuredScheme, const QString &configuredAppLinkDomain = QString());

    // Canonical admin-side assembly of the v1 custom-scheme form from this invitation's
    // own fields. Returns an invalid QUrl (isEmpty()/!isValid()) if the assembled result
    // would exceed the 2048 UTF-8 byte budget - the caller must have already trimmed
    // candidates to fit and must treat this as a hard failure, not "trim and retry".
    QUrl toUrl(const QString &scheme) const;

    bool isValid() const;
    ParseError error() const;

    QUuid uuid() const;
    QString name() const;
    QByteArray token() const;
    QList<QUrl> candidates() const;

    // The core's exact canonical encoding: 44 ASCII bytes, exactly one trailing '=',
    // decoding to exactly 32 bytes, with the decoded bytes re-encoding back to the same
    // 44 bytes (rejects non-canonical encodings a lenient decoder might still accept).
    static bool isCanonicalToken(const QByteArray &token);

    // Validates a single candidate against the shared-contract rules (scheme allowlist,
    // host/port/userinfo/fragment/query, tunnel UUID match) and normalizes it (lowercase
    // scheme/host, canonical tunnel query) in place. Returns false, leaving url
    // unspecified, if the candidate is not usable. Public so admin-side assembly (task 3)
    // can validate/normalize its own gathered candidates with the exact same rules the
    // parser enforces on the way in, rather than duplicating them.
    static bool validateAndNormalizeCandidate(QUrl &url, const QUuid &invitationUuid);

    static const int MaxEncodedUrlBytes = 2048;
    static const int MaxNameBytes = 128;
    static const int MaxCandidates = 8;

private:

    ParseError m_error = ParseError::NoError;
    QUuid m_uuid;
    QString m_name;
    QByteArray m_token;
    QList<QUrl> m_candidates;
};

#endif // INVITATION_H
