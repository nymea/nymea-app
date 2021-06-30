/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
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
    void addScriptReply(int id, const QString &scriptError, const QUuid &scriptId, const QStringList &errors);
    void editScriptReply(int id, const QString &scriptError, const QStringList &errors);
    void renameScriptReply(int id, const QString &scriptError);
    void removeScriptReply(int id, const QString &scriptError);
    void fetchScriptReply(int id, const QString &scriptError, const QString &content);

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
