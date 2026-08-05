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

#include "invitationcreatecontroller.h"

#include "connection/invitation.h"
#include "connection/nymeahost.h"
#include "configuration/nymeaconfiguration.h"
#include "configuration/serverconfiguration.h"
#include "configuration/serverconfigurations.h"

#include <QSet>
#include <QUrlQuery>

#include "logging.h"
NYMEA_LOGGING_CATEGORY(dcInvitation, "Invitation")

InvitationCreateController::InvitationCreateController(QObject *parent): QObject(parent)
{
}

Engine *InvitationCreateController::engine() const
{
    return m_engine;
}

void InvitationCreateController::setEngine(Engine *engine)
{
    if (m_engine == engine) {
        return;
    }
    m_engine = engine;
    emit engineChanged();
}

UserManager *InvitationCreateController::userManager() const
{
    return m_userManager;
}

void InvitationCreateController::setUserManager(UserManager *userManager)
{
    if (m_userManager == userManager) {
        return;
    }
    if (m_userManager) {
        disconnect(m_userManager, &UserManager::createInvitationReply, this, &InvitationCreateController::onCreateInvitationReply);
    }
    m_userManager = userManager;
    if (m_userManager) {
        connect(m_userManager, &UserManager::createInvitationReply, this, &InvitationCreateController::onCreateInvitationReply);
    }
    emit userManagerChanged();
}

QString InvitationCreateController::scheme() const
{
    return m_scheme;
}

void InvitationCreateController::setScheme(const QString &scheme)
{
    if (m_scheme == scheme) {
        return;
    }
    m_scheme = scheme;
    emit schemeChanged();
}

bool InvitationCreateController::busy() const
{
    return m_busy;
}

QStringList InvitationCreateController::previewDestinations() const
{
    QStringList result;
    foreach (const QUrl &url, m_previewCandidates) {
        result.append(QStringLiteral("%1://%2:%3").arg(url.scheme(), url.host()).arg(url.port()));
    }
    return result;
}

int InvitationCreateController::previewOmittedCount() const
{
    return m_previewOmittedCount;
}

bool InvitationCreateController::previewUsable() const
{
    return !m_previewCandidates.isEmpty();
}

bool InvitationCreateController::previewAllLanOnly() const
{
    if (m_previewCandidates.isEmpty()) {
        return false;
    }
    foreach (const QUrl &url, m_previewCandidates) {
        if (url.scheme() == QStringLiteral("tunnels")) {
            return false;
        }
    }
    return true;
}

QString InvitationCreateController::link() const
{
    return m_link;
}

QString InvitationCreateController::errorMessage() const
{
    return m_errorMessage;
}

QList<QUrl> InvitationCreateController::gatherCandidates() const
{
    QList<QUrl> secureFirst;
    QList<QUrl> insecure;

    if (m_engine && m_engine->jsonRpcClient() && m_engine->jsonRpcClient()->currentHost()) {
        static const QSet<QString> allowedSchemes = {
            QStringLiteral("nymea"), QStringLiteral("nymeas"), QStringLiteral("wss"), QStringLiteral("tunnels")
        };
        const QUuid uuid = m_engine->jsonRpcClient()->serverUuid();
        Connections *connections = m_engine->jsonRpcClient()->currentHost()->connections();
        for (int i = 0; i < connections->rowCount(); i++) {
            Connection *connection = connections->get(i);
            if (!connection || !connection->online()) {
                continue;
            }
            if (connection->bearerType() == Connection::BearerTypeLoopback
                    || connection->bearerType() == Connection::BearerTypeBluetooth) {
                continue;
            }
            if (!allowedSchemes.contains(connection->url().scheme().toLower())) {
                continue;
            }
            QUrl url = connection->url();
            if (!Invitation::validateAndNormalizeCandidate(url, uuid)) {
                continue;
            }
            if (connection->secure()) {
                secureFirst.append(url);
            } else {
                insecure.append(url);
            }
        }
    }

    QList<QUrl> ordered = secureFirst + insecure;

    if (m_engine && m_engine->nymeaConfiguration() && m_engine->jsonRpcClient()) {
        const QUuid uuid = m_engine->jsonRpcClient()->serverUuid();
        TunnelProxyServerConfigurations *tunnelConfigurations = m_engine->nymeaConfiguration()->tunnelProxyServerConfigurations();
        for (int i = 0; i < tunnelConfigurations->rowCount(); i++) {
            TunnelProxyServerConfiguration *configuration = tunnelConfigurations->getTunnelProxyServerConfiguration(i);
            if (!configuration || !configuration->sslEnabled()) {
                continue;
            }
            QUrl url;
            url.setScheme(QStringLiteral("tunnels"));
            url.setHost(configuration->address());
            url.setPort(configuration->port());
            QUrlQuery query;
            query.addQueryItem(QStringLiteral("uuid"), uuid.toString());
            url.setQuery(query);
            if (!Invitation::validateAndNormalizeCandidate(url, uuid)) {
                continue;
            }
            ordered.append(url);
        }
    }

    // Dedup while preserving order, matching the parser's own rule; cap at 8 here too so
    // trimToBudget() never has to consider more than the contract's own maximum.
    QList<QUrl> deduped;
    QSet<QString> seen;
    foreach (const QUrl &url, ordered) {
        QString key = url.toString(QUrl::FullyEncoded);
        if (seen.contains(key)) {
            continue;
        }
        seen.insert(key);
        deduped.append(url);
        if (deduped.size() >= Invitation::MaxCandidates) {
            break;
        }
    }

    return deduped;
}

void InvitationCreateController::trimToBudget(const QList<QUrl> &gathered, QList<QUrl> &retained, int &omittedCount) const
{
    retained = gathered;
    omittedCount = 0;

    if (retained.isEmpty() || !m_engine || !m_engine->jsonRpcClient()) {
        return;
    }

    const QUuid uuid = m_engine->jsonRpcClient()->serverUuid();
    QString name = m_engine->jsonRpcClient()->serverName();
    // Bound to the same 128 UTF-8 byte cap Invitation::fromUrl() enforces on the way in.
    QByteArray nameUtf8 = name.toUtf8();
    if (nameUtf8.size() > Invitation::MaxNameBytes) {
        name = QString::fromUtf8(nameUtf8.left(Invitation::MaxNameBytes));
    }
    // A real canonical 44-byte token, close to worst-case percent-encoding weight, used
    // only to measure whether the assembled link fits - the real token is unknown until
    // Users.CreateInvitation actually replies.
    const QByteArray placeholderToken = QByteArray(32, char(0xFF)).toBase64();

    while (!retained.isEmpty()) {
        Invitation candidateInvitation(uuid, name, placeholderToken, retained);
        if (!candidateInvitation.toUrl(m_scheme).isEmpty()) {
            break;
        }
        retained.removeLast();
        omittedCount++;
    }
}

void InvitationCreateController::updatePreview()
{
    QList<QUrl> gathered = gatherCandidates();
    QList<QUrl> retained;
    int omitted = 0;
    trimToBudget(gathered, retained, omitted);

    m_previewCandidates = retained;
    m_previewOmittedCount = omitted;
    emit previewChanged();
}

void InvitationCreateController::createInvitation(const QString &username, int validityDurationSeconds, int tokenValidityDurationSeconds)
{
    if (m_busy || !m_userManager || m_previewCandidates.isEmpty()) {
        return;
    }
    setErrorMessage(QString());
    setBusy(true);
    m_pendingCommandId = m_userManager->createInvitation(username, validityDurationSeconds, tokenValidityDurationSeconds);
}

void InvitationCreateController::clear()
{
    setLink(QString());
    setErrorMessage(QString());
    m_pendingCommandId = -1;
}

void InvitationCreateController::onCreateInvitationReply(int id, UserManager::UserError error, const QByteArray &token, const QUuid &invitationId)
{
    if (id != m_pendingCommandId) {
        // Stale reply from an already-abandoned attempt (e.g. clear() was called and a
        // new one started since) - ignore rather than overwrite the active result.
        return;
    }
    m_pendingCommandId = -1;
    setBusy(false);

    if (error != UserManager::UserErrorNoError || token.isEmpty()) {
        qCWarning(dcInvitation()) << "Create invitation failed:" << error;
        setErrorMessage(tr("Could not create the invitation. (Error code: %1)").arg(error));
        return;
    }

    Invitation invitation(m_engine->jsonRpcClient()->serverUuid(), m_engine->jsonRpcClient()->serverName(), token, m_previewCandidates);
    QUrl url = invitation.toUrl(m_scheme);
    if (url.isEmpty()) {
        // Assembly unexpectedly failed after a successful mint (the real token's
        // percent-encoded size differed enough from the preview's placeholder to tip the
        // payload over budget): never leave an unshareable invitation live on the server.
        qCWarning(dcInvitation()) << "Assembled invitation link exceeds the size budget after mint; removing" << invitationId;
        setErrorMessage(tr("The invitation could not be assembled. It has been removed - please try again with fewer destinations."));
        m_userManager->removeInvitation(invitationId);
        m_userManager->refreshInvitations();
        return;
    }

    setLink(url.toString());
    emit created();
}

void InvitationCreateController::setBusy(bool busy)
{
    if (m_busy == busy) {
        return;
    }
    m_busy = busy;
    emit busyChanged();
}

void InvitationCreateController::setLink(const QString &link)
{
    if (m_link == link) {
        return;
    }
    m_link = link;
    emit linkChanged();
}

void InvitationCreateController::setErrorMessage(const QString &errorMessage)
{
    if (m_errorMessage == errorMessage) {
        return;
    }
    m_errorMessage = errorMessage;
    emit errorMessageChanged();
}
