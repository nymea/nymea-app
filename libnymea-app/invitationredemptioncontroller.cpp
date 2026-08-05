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

#include "invitationredemptioncontroller.h"

#include <QTimer>

#include "logging.h"
NYMEA_LOGGING_CATEGORY(dcInvitationRedemption, "InvitationRedemption")

namespace {
Connection::BearerType bearerTypeForScheme(const QString &scheme)
{
    if (scheme == QStringLiteral("tunnels")) {
        return Connection::BearerTypeWan;
    }
    return Connection::BearerTypeLan;
}

bool isSecureScheme(const QString &scheme)
{
    return scheme == QStringLiteral("nymeas") || scheme == QStringLiteral("wss") || scheme == QStringLiteral("tunnels");
}
}

InvitationRedemptionController::InvitationRedemptionController(QObject *parent): QObject(parent)
{
    m_candidateTimer = new QTimer(this);
    m_candidateTimer->setSingleShot(true);
    connect(m_candidateTimer, &QTimer::timeout, this, &InvitationRedemptionController::onCandidateTimeout);

    m_overallDeadlineTimer = new QTimer(this);
    m_overallDeadlineTimer->setSingleShot(true);
    connect(m_overallDeadlineTimer, &QTimer::timeout, this, &InvitationRedemptionController::onOverallDeadline);
}

InvitationRedemptionController::~InvitationRedemptionController()
{
    teardownProbe();
}

NymeaHosts *InvitationRedemptionController::nymeaHosts() const
{
    return m_nymeaHosts;
}

void InvitationRedemptionController::setNymeaHosts(NymeaHosts *nymeaHosts)
{
    if (m_nymeaHosts == nymeaHosts) {
        return;
    }
    m_nymeaHosts = nymeaHosts;
    emit nymeaHostsChanged();
}

QString InvitationRedemptionController::scheme() const
{
    return m_scheme;
}

void InvitationRedemptionController::setScheme(const QString &scheme)
{
    if (m_scheme == scheme) {
        return;
    }
    m_scheme = scheme;
    emit schemeChanged();
}

QString InvitationRedemptionController::deviceLabel() const
{
    return m_deviceLabel;
}

void InvitationRedemptionController::setDeviceLabel(const QString &deviceLabel)
{
    if (m_deviceLabel == deviceLabel) {
        return;
    }
    m_deviceLabel = deviceLabel;
    emit deviceLabelChanged();
}

InvitationRedemptionController::State InvitationRedemptionController::state() const
{
    return m_state;
}

QString InvitationRedemptionController::confirmationServerName() const
{
    if (m_state != State::AwaitingConfirmation) {
        return QString();
    }
    return m_invitation.name();
}

QString InvitationRedemptionController::confirmationHost() const
{
    if (m_state != State::AwaitingConfirmation) {
        return QString();
    }
    return m_currentCandidate.host();
}

int InvitationRedemptionController::confirmationPort() const
{
    if (m_state != State::AwaitingConfirmation) {
        return -1;
    }
    return m_currentCandidate.port(-1);
}

QString InvitationRedemptionController::confirmationTransport() const
{
    if (m_state != State::AwaitingConfirmation) {
        return QString();
    }
    return transportLabel(m_currentCandidate);
}

bool InvitationRedemptionController::confirmationSecure() const
{
    if (m_state != State::AwaitingConfirmation) {
        return false;
    }
    return isSecureScheme(m_currentCandidate.scheme());
}

InvitationRedemptionController::Result InvitationRedemptionController::result() const
{
    return m_result;
}

QString InvitationRedemptionController::errorMessage() const
{
    return m_errorMessage;
}

QString InvitationRedemptionController::transportLabel(const QUrl &candidate) const
{
    const QString candidateScheme = candidate.scheme();
    if (candidateScheme == QStringLiteral("nymea")) {
        return tr("Local network (unencrypted)");
    }
    if (candidateScheme == QStringLiteral("nymeas")) {
        return tr("Local network (encrypted)");
    }
    if (candidateScheme == QStringLiteral("wss")) {
        return tr("Local network (encrypted, WebSocket)");
    }
    if (candidateScheme == QStringLiteral("tunnels")) {
        return tr("Remote tunnel (encrypted)");
    }
    return candidateScheme;
}

bool InvitationRedemptionController::handleUrl(const QUrl &url, const QUuid &eventId)
{
    if (eventId == m_activeEventId || m_recentEventIds.contains(eventId)) {
        return false;
    }

    m_recentEventIds.append(eventId);
    while (m_recentEventIds.size() > MaxRecentEventIds) {
        m_recentEventIds.removeFirst();
    }

    if (m_state != State::Idle) {
        // Busy (including an unacknowledged terminal result): queue rather than
        // silently overwrite the active/just-finished secret.
        m_queuedRequests.enqueue(qMakePair(url, eventId));
        return true;
    }

    m_activeEventId = eventId;
    startValidation(url);
    return true;
}

void InvitationRedemptionController::startValidation(const QUrl &url)
{
    setState(State::Validating);
    m_invitation = Invitation::fromUrl(url, m_scheme);
    if (!m_invitation.isValid()) {
        finish(Result::Protocol, tr("This invitation link is not valid, or is not supported by this app version."));
        return;
    }

    m_remainingCandidates = m_invitation.candidates();
    m_overallDeadlineTimer->start(OverallDeadlineMs);
    tryNextCandidate();
}

void InvitationRedemptionController::tryNextCandidate()
{
    teardownProbe();

    if (m_remainingCandidates.isEmpty()) {
        finish(Result::Transport, tr("None of the destinations in this invitation could be reached."));
        return;
    }

    m_currentCandidate = m_remainingCandidates.takeFirst();
    setState(State::TryingCandidate);
    qCDebug(dcInvitationRedemption()) << "Trying candidate" << m_currentCandidate.scheme() << m_currentCandidate.host() << m_currentCandidate.port();

    m_probeHost = new NymeaHost(this);
    // Deliberately left with a null UUID: helloReply() only resolves and persists the
    // real UUID after the server actually replies. A null UUID can never collide with a
    // stored QSettings token for a real host even without credential-free probe mode,
    // which is applied as well, defense in depth.
    m_probeHost->connections()->addConnection(m_currentCandidate, bearerTypeForScheme(m_currentCandidate.scheme()),
                                               isSecureScheme(m_currentCandidate.scheme()),
                                               QStringLiteral("invitation-probe"));

    m_probeClient = new JsonRpcClient(this);
    m_probeClient->setCredentialFreeProbeMode(true);
    connect(m_probeClient, &JsonRpcClient::transportConnectedChanged, this, &InvitationRedemptionController::onProbeConnectedChanged);
    connect(m_probeClient, &JsonRpcClient::responseReceived, this, &InvitationRedemptionController::onProbeHelloResponseReceived);
    connect(m_probeClient, &JsonRpcClient::authenticateWithTokenFinished, this, &InvitationRedemptionController::onAuthenticateWithTokenFinished);

    m_candidateTimer->start(CandidateTimeoutMs);
    m_probeClient->connectToHost(m_probeHost, m_probeHost->connections()->get(0));
}

void InvitationRedemptionController::onCandidateTimeout()
{
    qCDebug(dcInvitationRedemption()) << "Candidate timed out" << m_currentCandidate;
    tryNextCandidate();
}

void InvitationRedemptionController::onOverallDeadline()
{
    finish(Result::Transport, tr("Could not reach any destination in this invitation in time."));
}

void InvitationRedemptionController::onProbeConnectedChanged(bool connected)
{
    if (connected) {
        if (m_state == State::TryingCandidate) {
            setState(State::AwaitingHello);
        }
        return;
    }
    // Transport dropped (connect failure or disconnect) before/without a usable Hello
    // reply - fully cancel this attempt and advance to the next candidate.
    if (m_state == State::TryingCandidate || m_state == State::AwaitingHello) {
        tryNextCandidate();
    }
}

void InvitationRedemptionController::onProbeHelloResponseReceived(int commandId, const QVariantMap &response)
{
    Q_UNUSED(commandId)
    Q_UNUSED(response)
    if (m_state != State::AwaitingHello && m_state != State::TryingCandidate) {
        return;
    }
    // One-shot: this connection only exists to catch the automatic Hello reply. The
    // later AuthenticateWithToken reply is also a generic responseReceived emission,
    // but is handled precisely via authenticateWithTokenFinished instead.
    disconnect(m_probeClient, &JsonRpcClient::responseReceived, this, &InvitationRedemptionController::onProbeHelloResponseReceived);
    m_candidateTimer->stop();

    const QUuid reportedUuid = m_probeClient->serverUuid();
    const bool available = m_probeClient->invitationApiAvailable();
    qCDebug(dcInvitationRedemption()) << "Probe Hello reply. Reported UUID:" << reportedUuid << "expected:" << m_invitation.uuid() << "invitationApiAvailable:" << available;

    if (reportedUuid.isNull() || reportedUuid != m_invitation.uuid()) {
        // A mismatch permanently rejects this candidate and is never accepted by
        // updating the host UUID - continue only if another candidate might reach the
        // requested UUID.
        tryNextCandidate();
        return;
    }
    if (!available) {
        // Matching UUID but protocol <10.3 or invitationsAvailable missing/false/
        // malformed: authoritative unavailable result for this target - continue only
        // if another candidate might reach a different, invitation-capable target.
        tryNextCandidate();
        return;
    }

    setState(State::AwaitingConfirmation);
    emit confirmationChanged();
}

void InvitationRedemptionController::confirmCandidate()
{
    if (m_state != State::AwaitingConfirmation || !m_probeClient) {
        return;
    }
    setState(State::Redeeming);
    // A local refusal inside authenticateWithToken() (invalid derived device name - it
    // can't refuse for invitationApiAvailable, just confirmed true) emits
    // authenticateWithTokenFinished(-1, false, ...) synchronously, reentrantly, before
    // the call below returns - i.e. before this line's assignment has happened.
    // onAuthenticateWithTokenFinished still matches it correctly because
    // m_pendingAuthCommandId was already reset to -1 by tryNextCandidate()'s
    // teardownProbe() and nothing else sets it in between.
    m_pendingAuthCommandId = m_probeClient->authenticateWithToken(m_invitation.token(), m_deviceLabel);
}

void InvitationRedemptionController::onAuthenticateWithTokenFinished(int commandId, bool success, JsonRpcClient::AuthenticateWithTokenReason reason)
{
    if (m_state != State::Redeeming || commandId != m_pendingAuthCommandId) {
        // Stale reply from an already-abandoned attempt - never let it complete or fail
        // a newer one.
        return;
    }

    if (success) {
        // The regular token is already persisted by JsonRpcClient itself, keyed by the
        // real server UUID resolved during the probe Hello. Merge a host entry into the
        // shared model, if provided, so normal reconnect flow can find it afterwards.
        if (m_nymeaHosts) {
            NymeaHost *host = m_nymeaHosts->find(m_invitation.uuid());
            if (!host) {
                host = m_nymeaHosts->createHost(m_invitation.name().isEmpty() ? m_currentCandidate.host() : m_invitation.name(),
                                                 m_currentCandidate, bearerTypeForScheme(m_currentCandidate.scheme()));
                host->setUuid(m_invitation.uuid());
            } else if (!host->connections()->find(m_currentCandidate)) {
                host->connections()->addConnection(m_currentCandidate, bearerTypeForScheme(m_currentCandidate.scheme()),
                                                     isSecureScheme(m_currentCandidate.scheme()), tr("Invitation"), true);
            }
        }
        finish(Result::Success, QString());
        return;
    }

    switch (reason) {
    case JsonRpcClient::AuthenticateWithTokenReason::InvalidOrExpired:
        // Authoritative: the secret itself is bad server-side, not a transport/candidate
        // issue - do not try any other candidate.
        finish(Result::InvalidOrExpired, tr("This invitation has already been used, has expired, or was revoked."));
        break;
    case JsonRpcClient::AuthenticateWithTokenReason::Unsupported:
        finish(Result::Unsupported, tr("This server no longer supports invitations."));
        break;
    case JsonRpcClient::AuthenticateWithTokenReason::Transport:
    case JsonRpcClient::AuthenticateWithTokenReason::Protocol:
    case JsonRpcClient::AuthenticateWithTokenReason::Cancelled:
    case JsonRpcClient::AuthenticateWithTokenReason::NoError:
        // The outcome is ambiguous - the server may have committed the redemption
        // already before the connection was lost. Never blindly resend the secret;
        // report the ambiguity instead. There is no protocol query to check whether a
        // one-time token was already redeemed without redeeming it, so a fresh
        // invitation is the only way to recover if this one did commit.
        finish(Result::Transport, tr("The connection was lost while redeeming this invitation. It may or may not have "
                                      "already succeeded - try reopening the link, or ask for a new invitation if that fails."));
        break;
    }
}

void InvitationRedemptionController::cancel()
{
    if (m_state == State::Idle
            || m_state == State::Completed || m_state == State::Failed || m_state == State::Cancelled) {
        return;
    }
    finish(Result::Cancelled, QString());
}

void InvitationRedemptionController::acknowledge()
{
    if (m_state != State::Completed && m_state != State::Failed && m_state != State::Cancelled) {
        return;
    }
    startNextQueuedOrIdle();
}

void InvitationRedemptionController::startNextQueuedOrIdle()
{
    m_result = Result::NoResult;
    m_errorMessage.clear();

    if (m_queuedRequests.isEmpty()) {
        setState(State::Idle);
        return;
    }

    QPair<QUrl, QUuid> next = m_queuedRequests.dequeue();
    m_activeEventId = next.second;
    startValidation(next.first);
}

void InvitationRedemptionController::teardownProbe()
{
    m_candidateTimer->stop();
    if (m_probeClient) {
        m_probeClient->disconnect(this);
        m_probeClient->disconnectFromHost();
        m_probeClient->deleteLater();
        m_probeClient = nullptr;
    }
    if (m_probeHost) {
        m_probeHost->deleteLater();
        m_probeHost = nullptr;
    }
    m_pendingAuthCommandId = -1;
}

void InvitationRedemptionController::finish(Result result, const QString &errorMessage)
{
    teardownProbe();
    m_overallDeadlineTimer->stop();
    m_remainingCandidates.clear();
    m_invitation = Invitation(); // Clears the pending secret from memory.

    m_result = result;
    m_errorMessage = errorMessage;
    State terminalState = State::Failed;
    if (result == Result::Success) {
        terminalState = State::Completed;
    } else if (result == Result::Cancelled) {
        terminalState = State::Cancelled;
    }
    setState(terminalState);
    emit redemptionFinished(result, errorMessage);
}

void InvitationRedemptionController::setState(State state)
{
    if (m_state == state) {
        return;
    }
    m_state = state;
    emit stateChanged();
}
