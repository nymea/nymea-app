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

bool Engine::connected() const
{
    return m_connected;
}

DeviceManager *Engine::deviceManager()
{
    return m_deviceManager;
}

JsonRpcClient *Engine::jsonRpcClient()
{
    return m_jsonRpcClient;
}

WebsocketInterface *Engine::interface()
{
    return m_interface;
}

void Engine::connectGuh()
{
    m_interface->setUrl("ws://loop.local:4444");
    m_interface->enable();
}

Engine::Engine(QObject *parent) :
    QObject(parent),
    m_connected(false),
    m_deviceManager(new DeviceManager(this)),
    m_jsonRpcClient(new JsonRpcClient(this)),
    m_interface(new WebsocketInterface(this))
{
    connect(m_interface, &WebsocketInterface::connectedChanged, this, &Engine::onConnectedChanged);
    connect(m_interface, &WebsocketInterface::dataReady, m_jsonRpcClient, &JsonRpcClient::dataReceived);

}

void Engine::setConnected(const bool &connected)
{
    if (m_connected != connected) {
        m_connected = connected;
        emit connectedChanged(m_connected);
    }
}

void Engine::onConnectedChanged(const bool &connected)
{
    setConnected(connected);

    // delete all data
    if (!connected) {
        deviceManager()->devices()->clearModel();
        deviceManager()->deviceClasses()->clearModel();
        deviceManager()->vendors()->clearModel();
        deviceManager()->plugins()->clearModel();
    } else {
        Engine::instance()->jsonRpcClient()->getVendors();
    }
}
