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

#ifndef INVITATIONREDEMPTIONCONTROLLER_H
#define INVITATIONREDEMPTIONCONTROLLER_H

#include <QObject>
#include <QQueue>
#include <QUrl>
#include <QUuid>

#include "connection/invitation.h"
#include "connection/nymeahosts.h"
#include "jsonrpc/jsonrpcclient.h"

// Engine-level guest redemption controller (work package 02, Task 4). Both native deep
// link delivery (work package 03's PlatformHelper::urlReceived) and the base
// ConnectionWizard/ManualConnectionEntry paste action call into handleUrl(); every
// pending secret lives only in this object's memory and is cleared on every terminal
// path (Completed/Failed/Cancelled) and on destruction.
//
// Scope note: this first version implements the full credential-free-probe /
// per-candidate-confirmation / ordered-retry state machine and resolved transport trust
// option B (see README.md's decision record). It does NOT yet implement the
// existing-session ambiguity handling (a live or stored token already present for the
// target host) - every redemption attempt currently assumes a clean, tokenless target
// connection. That is intentionally deferred to its own follow-up (COMMITS.md item 7),
// since it depends on the app's multi-tab/multi-Engine session model in ways this
// engine-level controller does not otherwise need to know about.
class InvitationRedemptionController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(NymeaHosts *nymeaHosts READ nymeaHosts WRITE setNymeaHosts NOTIFY nymeaHostsChanged)
    Q_PROPERTY(QString scheme READ scheme WRITE setScheme NOTIFY schemeChanged)
    Q_PROPERTY(QString deviceLabel READ deviceLabel WRITE setDeviceLabel NOTIFY deviceLabelChanged)

    Q_PROPERTY(State state READ state NOTIFY stateChanged)

    // Populated only while state() == AwaitingConfirmation, for the confirmation UI.
    // Never includes the token or the complete invitation link.
    Q_PROPERTY(QString confirmationServerName READ confirmationServerName NOTIFY confirmationChanged)
    Q_PROPERTY(QString confirmationHost READ confirmationHost NOTIFY confirmationChanged)
    Q_PROPERTY(int confirmationPort READ confirmationPort NOTIFY confirmationChanged)
    Q_PROPERTY(QString confirmationTransport READ confirmationTransport NOTIFY confirmationChanged)
    Q_PROPERTY(bool confirmationSecure READ confirmationSecure NOTIFY confirmationChanged)

    Q_PROPERTY(Result result READ result NOTIFY redemptionFinished)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY redemptionFinished)

public:
    enum class State {
        Idle,
        Validating,
        AwaitingConfirmation,
        TryingCandidate,
        AwaitingHello,
        Redeeming,
        Completed,
        Failed,
        Cancelled
    };
    Q_ENUM(State)

    // Bounded result reason, mirroring JsonRpcClient::AuthenticateWithTokenReason at the
    // controller level (this enum additionally covers pure local/candidate-exhaustion
    // outcomes that never reach an AuthenticateWithToken call at all).
    enum class Result {
        NoResult,
        Success,
        Unsupported,
        InvalidOrExpired,
        Transport,
        Cancelled,
        Protocol
    };
    Q_ENUM(Result)

    explicit InvitationRedemptionController(QObject *parent = nullptr);
    ~InvitationRedemptionController() override;

    NymeaHosts *nymeaHosts() const;
    void setNymeaHosts(NymeaHosts *nymeaHosts);

    QString scheme() const;
    void setScheme(const QString &scheme);

    QString deviceLabel() const;
    void setDeviceLabel(const QString &deviceLabel);

    State state() const;

    QString confirmationServerName() const;
    QString confirmationHost() const;
    int confirmationPort() const;
    QString confirmationTransport() const;
    bool confirmationSecure() const;

    Result result() const;
    QString errorMessage() const;

    // Entry point for both native deep-link delivery and the paste/import fallback.
    // eventId dedups redelivery of the same event (retained across the lifetime of this
    // object, bounded to the most recent 16). Returns false without starting anything if
    // eventId was already handled or is currently the active attempt. A newly received
    // invitation while one is already in flight is queued, not applied over the active
    // one, and is processed once the current attempt reaches a terminal state.
    Q_INVOKABLE bool handleUrl(const QUrl &url, const QUuid &eventId);

    // Proceeds with the candidate currently shown for confirmation. No-op outside
    // AwaitingConfirmation.
    Q_INVOKABLE void confirmCandidate();

    // Aborts the entire in-flight attempt (not just the current candidate) and clears
    // the pending secret. Safe to call from any state, including Idle.
    Q_INVOKABLE void cancel();

    // Dismisses a terminal result (Completed/Failed/Cancelled), returning state() to
    // Idle and starting the next queued invitation, if any. The UI calls this once it is
    // done showing the result - state is intentionally not auto-reset immediately on
    // reaching a terminal state, so it stays observable until dismissed. No-op outside a
    // terminal state.
    Q_INVOKABLE void acknowledge();

    // Allocates a fresh event id for a paste/import action, matching the same
    // dedup-by-eventId path used for native deep link delivery. QML has no built-in
    // UUID generator to use for this itself.
    Q_INVOKABLE QUuid generateEventId() const;

signals:
    void nymeaHostsChanged();
    void schemeChanged();
    void deviceLabelChanged();
    void stateChanged();
    void confirmationChanged();
    // Reason is Result::NoResult while an attempt is still in progress; only meaningful
    // once state() is Completed/Failed/Cancelled.
    void redemptionFinished(Result result, const QString &errorMessage);

private slots:
    void onCandidateTimeout();
    void onOverallDeadline();
    void onProbeConnectedChanged(bool connected);
    void onProbeHelloResponseReceived(int commandId, const QVariantMap &response);
    void onAuthenticateWithTokenFinished(int commandId, bool success, JsonRpcClient::AuthenticateWithTokenReason reason);

private:
    void setState(State state);
    void startValidation(const QUrl &url);
    void startNextQueuedOrIdle();
    void tryNextCandidate();
    void teardownProbe();
    void finish(Result result, const QString &errorMessage);
    QString transportLabel(const QUrl &candidate) const;

    NymeaHosts *m_nymeaHosts = nullptr;
    QString m_scheme = QStringLiteral("nymea");
    QString m_deviceLabel = QStringLiteral("nymea-app");

    State m_state = State::Idle;
    Result m_result = Result::NoResult;
    QString m_errorMessage;

    Invitation m_invitation;
    QList<QUrl> m_remainingCandidates;
    QUrl m_currentCandidate;
    int m_pendingAuthCommandId = -1;

    JsonRpcClient *m_probeClient = nullptr;
    NymeaHost *m_probeHost = nullptr;

    QTimer *m_candidateTimer = nullptr;
    QTimer *m_overallDeadlineTimer = nullptr;

    QList<QUuid> m_recentEventIds;
    QUuid m_activeEventId;
    QQueue<QPair<QUrl, QUuid>> m_queuedRequests;

    static const int CandidateTimeoutMs = 8000;
    static const int OverallDeadlineMs = 60000;
    static const int MaxRecentEventIds = 16;
};

#endif // INVITATIONREDEMPTIONCONTROLLER_H
