// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef EVDASHMANAGER_H
#define EVDASHMANAGER_H

#include <QObject>
#include <engine.h>

#include "evdashusers.h"

class EvDashManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged FINAL)
    Q_PROPERTY(EvDashUsers *users READ users CONSTANT FINAL)

public:
    enum EvDashError {
        EvDashErrorNoError = 0,
        EvDashErrorBackendError,
        EvDashErrorDuplicateUser,
        EvDashErrorUserNotFound,
        EvDashErrorBadPassword
    };
    Q_ENUM(EvDashError)

    explicit EvDashManager(QObject *parent = nullptr);
    ~EvDashManager();

    EvDashUsers *users() const;

    Engine* engine() const;
    void setEngine(Engine *engine);

    bool enabled() const;
    int setEnabled(bool enabled);

    Q_INVOKABLE int addUser(const QString &username, const QString &password);
    Q_INVOKABLE int removeUser(const QString &username);

signals:
    void engineChanged();
    void enabledChanged();

    void setEnabledReply(int commandId, EvDashManager::EvDashError error);
    void addUserReply(int commandId, EvDashManager::EvDashError error);
    void removeUserReply(int commandId, EvDashManager::EvDashError error);

private slots:
    void notificationReceived(const QVariantMap &data);

    void getEnabledResponse(int commandId, const QVariantMap &params);
    void setEnabledResponse(int commandId, const QVariantMap &params);

    void getUsersResponse(int commandId, const QVariantMap &params);
    void addUserResponse(int commandId, const QVariantMap &params);
    void removeUserResponse(int commandId, const QVariantMap &params);

private:
    Engine *m_engine = nullptr;
    bool m_enabled = false;
    EvDashUsers *m_users = nullptr;

};

#endif // EVDASHMANAGER_H
