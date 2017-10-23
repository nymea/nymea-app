/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of guh-control.                                      *
 *                                                                         *
 *  guh-control is free software: you can redistribute it and/or modify    *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  guh-control is distributed in the hope that it will be useful,         *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with guh-control. If not, see <http://www.gnu.org/licenses/>.    *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "engine.h"

#include "tcpsocketinterface.h"

Engine* Engine::s_instance = 0;

Engine *Engine::instance()
{
    if (!s_instance)
        s_instance = new Engine();

    return s_instance;
}

QObject *Engine::qmlInstance(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    Q_UNUSED(qmlEngine)
    Q_UNUSED(jsEngine)

    return Engine::instance();
}

DeviceManager *Engine::deviceManager() const
{
    return m_deviceManager;
}

JsonRpcClient *Engine::jsonRpcClient() const
{
    return m_jsonRpcClient;
}

GuhConnection *Engine::connection() const
{
    return m_connection;
}

Engine::Engine(QObject *parent) :
    QObject(parent),
    m_connection(new GuhConnection(this)),
    m_jsonRpcClient(new JsonRpcClient(m_connection, this)),
    m_deviceManager(new DeviceManager(m_jsonRpcClient, this))
{
    connect(m_jsonRpcClient, &JsonRpcClient::connectedChanged, this, &Engine::onConnectedChanged);
}

void Engine::onConnectedChanged(bool connected)
{
    qDebug() << "Engine: connected changed:" << connected;
    deviceManager()->clear();
    if (connected) {
        if (!jsonRpcClient()->initialSetupRequired() && !jsonRpcClient()->authenticationRequired()) {
            deviceManager()->init();
        }
    }
}
