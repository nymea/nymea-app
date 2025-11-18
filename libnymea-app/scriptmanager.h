// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
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

#ifndef SCRIPTMANAGER_H
#define SCRIPTMANAGER_H

#include <QObject>

#include "jsonrpc/jsonrpcclient.h"

class Scripts;

class ScriptManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Scripts* scripts READ scripts CONSTANT)
    Q_PROPERTY(bool fetchingData READ fetchingData NOTIFY fetchingDataChanged)

public:
    enum ScriptError {
        ScriptErrorNoError,
        ScriptErrorScriptNotFound,
        ScriptErrorInvalidScript,
        ScriptErrorHardwareFailure
    };
    Q_ENUM(ScriptError)

    explicit ScriptManager(JsonRpcClient* jsonClient, QObject *parent = nullptr);

    void init();
    bool fetchingData() const;

    Scripts *scripts() const;

public slots:
    int addScript(const QString &name, const QString &content);
    int renameScript(const QUuid &id, const QString &name);
    int editScript(const QUuid &id, const QString &content);
    int removeScript(const QUuid &id);
    int fetchScript(const QUuid &id);

signals:
    void addScriptReply(int id, ScriptError status, const QUuid &scriptId, const QStringList &errors);
    void editScriptReply(int id, ScriptError status, const QStringList &errors);
    void renameScriptReply(int id, ScriptError status);
    void removeScriptReply(int id, ScriptError status);
    void fetchScriptReply(int id, ScriptError status, const QString &content);

    void scriptMessage(const QUuid &scriptId, const QString &type, const QString &message);
    void fetchingDataChanged();

private slots:
    void onScriptsFetched(int commandId, const QVariantMap &params);
    void onScriptFetched(int commandId, const QVariantMap &params);
    void onScriptAdded(int commandId, const QVariantMap &params);
    void onScriptEdited(int commandId, const QVariantMap &params);
    void onScriptRenamed(int commandId, const QVariantMap &params);
    void onScriptRemoved(int commandId, const QVariantMap &params);

    void onNotificationReceived(const QVariantMap &params);
private:
    JsonRpcClient* m_client = nullptr;
    Scripts *m_scripts = nullptr;
    bool m_fetchingData = false;
};

#endif // SCRIPTMANAGER_H
