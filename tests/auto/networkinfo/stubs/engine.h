// SPDX-License-Identifier: GPL-3.0-or-later
// Test stub replacing libnymea-app/engine.h for tst_networkinfo
#ifndef ENGINE_H
#define ENGINE_H

#include <QObject>

#include "jsonrpc/jsonrpcclient.h"

class Engine : public QObject
{
    Q_OBJECT
public:
    explicit Engine(QObject *parent = nullptr) : QObject(parent), m_client(new JsonRpcClient(this)) {}
    JsonRpcClient *jsonRpcClient() const { return m_client; }

private:
    JsonRpcClient *m_client = nullptr;
};

#endif // ENGINE_H
