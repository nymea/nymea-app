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

#ifndef ENGINE_H
#define ENGINE_H

#include <QObject>
#include <QQmlEngine>
#include <QJSEngine>

#include "devicemanager.h"
#include "guhinterface.h"
#include "jsonrpc/jsonrpcclient.h"


class RuleManager;

class Engine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(GuhConnection *connection READ connection CONSTANT)
    Q_PROPERTY(DeviceManager *deviceManager READ deviceManager CONSTANT)
    Q_PROPERTY(RuleManager *ruleManager READ ruleManager CONSTANT)
    Q_PROPERTY(JsonRpcClient *jsonRpcClient READ jsonRpcClient CONSTANT)

public:
    static Engine *instance();
    static QObject *qmlInstance(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

    bool connected() const;
    QString connectedHost() const;

    GuhConnection *connection() const;
    DeviceManager *deviceManager() const;
    RuleManager *ruleManager() const;
    JsonRpcClient *jsonRpcClient() const;

private:
    explicit Engine(QObject *parent = 0);
    static Engine *s_instance;

    GuhConnection *m_connection;
    JsonRpcClient *m_jsonRpcClient;
    DeviceManager *m_deviceManager;
    RuleManager *m_ruleManager;

private slots:
    void onConnectedChanged();

};

#endif // ENGINE_H
