/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2024, nymea GmbH
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

#include "serverdebugmanager.h"

#include "engine.h"
#include "logging.h"
#include "jsonrpc/jsonrpcclient.h"

NYMEA_LOGGING_CATEGORY(dcServerDebug, "ServerDebug")

ServerDebugManager::ServerDebugManager(JsonRpcClient *jsonClient, QObject *parent)
    : QObject{parent},
    m_jsonClient{jsonClient}
{

}

Engine *ServerDebugManager::engine() const
{
    return m_engine;
}

void ServerDebugManager::setEngine(Engine *engine)
{
    if (m_engine != engine) {

        if (m_engine)
            m_engine->jsonRpcClient()->unregisterNotificationHandler(this);

        m_engine = engine;
        emit engineChanged();

        init();
    }
}

bool ServerDebugManager::fetchingData() const
{
    return m_fetchingData;
}

void ServerDebugManager::getLoggingCategories()
{
    m_engine->jsonRpcClient()->sendCommand("Debug.GetLoggingCategories", this, "getLoggingCategoriesResponse");
}

void ServerDebugManager::getLoggingCategoriesResponse(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)
    QVariantList categories = params.value("params").toList();
    foreach (const QVariant &categoryVariant, categories) {
        QVariantMap categoryMap = categoryVariant.toMap();
        qCDebug(dcServerDebug()) << categoryMap.value("name").toString() << categoryMap.value("level").toString();
    }

}
