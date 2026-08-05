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

#ifndef INVITATIONCREATECONTROLLER_H
#define INVITATIONCREATECONTROLLER_H

#include <QObject>
#include <QUrl>
#include <QUuid>

#include "engine.h"
#include "usermanager.h"

// Single owner of Users.CreateInvitation for the admin create/show flow: gathers and
// trims candidates to fit the shared-contract size budget before minting, correlates the
// one in-flight create command so a duplicate submission (e.g. a fast double-tap) can
// never send two requests, and takes the clear one-time token exactly once - it is never
// cached anywhere else (not on this object beyond link()/clear(), not on the Invitations
// model, which only ever sees InvitationInfo - never a token).
class InvitationCreateController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Engine *engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(UserManager *userManager READ userManager WRITE setUserManager NOTIFY userManagerChanged)
    // Build-time branded custom scheme (README default "nymea"). Work package 03 owns the
    // actual per-branding scheme matrix; this just needs some value to assemble links with
    // until that wiring exists.
    Q_PROPERTY(QString scheme READ scheme WRITE setScheme NOTIFY schemeChanged)

    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)

    Q_PROPERTY(QStringList previewDestinations READ previewDestinations NOTIFY previewChanged)
    Q_PROPERTY(int previewOmittedCount READ previewOmittedCount NOTIFY previewChanged)
    Q_PROPERTY(bool previewUsable READ previewUsable NOTIFY previewChanged)
    Q_PROPERTY(bool previewAllLanOnly READ previewAllLanOnly NOTIFY previewChanged)

    Q_PROPERTY(QString link READ link NOTIFY linkChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)

public:
    explicit InvitationCreateController(QObject *parent = nullptr);

    Engine *engine() const;
    void setEngine(Engine *engine);
    UserManager *userManager() const;
    void setUserManager(UserManager *userManager);
    QString scheme() const;
    void setScheme(const QString &scheme);

    bool busy() const;

    QStringList previewDestinations() const;
    int previewOmittedCount() const;
    bool previewUsable() const;
    bool previewAllLanOnly() const;

    QString link() const;
    QString errorMessage() const;

    // Recomputes the candidate preview against the current engine/host state. The list is
    // never trimmed again after this - call again to refresh before retrying if the
    // connection state might have changed while a dialog was open.
    Q_INVOKABLE void updatePreview();

    // No-ops (does not send a request) while busy() is already true or the preview has no
    // usable candidate, so a dialog can simply always call this on submit.
    Q_INVOKABLE void createInvitation(const QString &username, int validityDurationSeconds, int tokenValidityDurationSeconds);

    // Clears the clear-text link/token from memory. Call when the result view closes.
    Q_INVOKABLE void clear();

signals:
    void engineChanged();
    void userManagerChanged();
    void schemeChanged();
    void busyChanged();
    void previewChanged();
    void linkChanged();
    void errorMessageChanged();
    void created();

private slots:
    void onCreateInvitationReply(int id, UserManager::UserError error, const QByteArray &token, const QUuid &invitationId);

private:
    // Priority order: current usable LAN connections (secure first; loopback/Bluetooth
    // and non-allowlisted schemes skipped), then every SSL-enabled tunnel-proxy
    // configuration. Each candidate is validated/normalized with the exact same rules
    // Invitation::fromUrl() enforces on the way in.
    QList<QUrl> gatherCandidates() const;

    // Feeds a placeholder (but real, canonical) invitation through Invitation::toUrl()
    // one candidate at a time to find how many of the gathered candidates actually fit
    // the 2048-byte budget, reusing its budget check instead of re-deriving byte counts.
    void trimToBudget(const QList<QUrl> &gathered, QList<QUrl> &retained, int &omittedCount) const;

    void setBusy(bool busy);
    void setLink(const QString &link);
    void setErrorMessage(const QString &errorMessage);

    Engine *m_engine = nullptr;
    UserManager *m_userManager = nullptr;
    QString m_scheme = QStringLiteral("nymea");

    bool m_busy = false;
    int m_pendingCommandId = -1;

    QList<QUrl> m_previewCandidates;
    int m_previewOmittedCount = 0;

    QString m_link;
    QString m_errorMessage;
};

#endif // INVITATIONCREATECONTROLLER_H
