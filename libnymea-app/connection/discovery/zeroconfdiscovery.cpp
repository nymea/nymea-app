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

#include "zeroconfdiscovery.h"

#include <QUuid>

#include "../nymeahost.h"
#include "logging.h"

NYMEA_LOGGING_CATEGORY(dcZeroConf, "ZeroConf")

ZeroconfDiscovery::ZeroconfDiscovery(NymeaHosts *nymeaHosts, QObject *parent) :
    QObject(parent),
    m_nymeaHosts(nymeaHosts)
{
#ifdef WITH_ZEROCONF
    // NOTE: There seem to be too many issues in QtZeroConf and IPv6.
    // See https://github.com/jbagg/QtZeroConf/issues/22
    // Limiting this to IPv4 for now...

    m_zeroconfJsonRPC = new QZeroConf(this);
    connect(m_zeroconfJsonRPC, &QZeroConf::serviceAdded, this, &ZeroconfDiscovery::serviceEntryAdded);
    connect(m_zeroconfJsonRPC, &QZeroConf::serviceUpdated, this, &ZeroconfDiscovery::serviceEntryAdded);
    connect(m_zeroconfJsonRPC, &QZeroConf::serviceRemoved, this, &ZeroconfDiscovery::serviceEntryRemoved);

    if (m_zeroconfJsonRPC->isValid()) {
        m_zeroconfJsonRPC->startBrowser("_jsonrpc._tcp", QAbstractSocket::IPv4Protocol);
        qCInfo(dcZeroConf()) << "Created service browser for _jsonrpc._tcp:" << m_zeroconfJsonRPC->browserExists();
    } else {
        qCWarning(dcZeroConf()) << "Failed to initialize service broeser for _jsonprc._tcp";
    }

    m_zeroconfWebSocket = new QZeroConf(this);
    connect(m_zeroconfWebSocket, &QZeroConf::serviceAdded, this, &ZeroconfDiscovery::serviceEntryAdded);
    connect(m_zeroconfWebSocket, &QZeroConf::serviceUpdated, this, &ZeroconfDiscovery::serviceEntryAdded);
    connect(m_zeroconfWebSocket, &QZeroConf::serviceRemoved, this, &ZeroconfDiscovery::serviceEntryRemoved);
    if (m_zeroconfWebSocket->isValid()) {
        m_zeroconfWebSocket->startBrowser("_ws._tcp", QAbstractSocket::IPv4Protocol);
        qCInfo(dcZeroConf()) << "Created service browser for _ws._tcp:" << m_zeroconfWebSocket->browserExists();
    } else {
        qCWarning(dcZeroConf()) << "Failed to initialize service browserr for _ws._tcp";
    }

#else
    qCInfo(dcZeroConf()) << "Zeroconf support not compiled in. Zeroconf will not be available.";
#endif
}

ZeroconfDiscovery::~ZeroconfDiscovery()
{
    qCInfo(dcZeroConf()) << "Shutting down service browsers";
}

bool ZeroconfDiscovery::available() const
{
#ifdef WITH_ZEROCONF
    return m_zeroconfJsonRPC->browserExists() || m_zeroconfWebSocket->browserExists();
#else
    return false;
#endif
}

bool ZeroconfDiscovery::discovering() const
{
    return available();
}

#ifdef WITH_ZEROCONF
void ZeroconfDiscovery::serviceEntryAdded(const QZeroConfService &entry)
{
    if (!entry->name().startsWith("nymea")) {
        // Skip non-nymea services altogether
        qCDebug(dcZeroConf()) << "Skipping service entry:" << entry << entry->ip() << entry->txt() << entry->type();
        return;
    }
    if (entry->ip().isNull()) {
        // Skip entries that don't have an ip address at all for some reason
        qCDebug(dcZeroConf()) << "Skipping service entry:" << entry << entry->ip() << entry->txt() << entry->type();
        return;
    }
    if (entry->ip().toString().startsWith("fe80")) {
        // Skip link-local-IPv6 results
        qCDebug(dcZeroConf()) << "Skipping service entry:" << entry << entry->ip() << entry->txt() << entry->type();
        return;
    }

    qCDebug(dcZeroConf()) << "Service discovered" << entry->type() << entry->name() << " IP:" << entry->ip().toString() << entry->txt();

    QUuid uuid;
    bool sslEnabled = false;
    QString serverName;
    QString version;
    foreach (const QByteArray &key, entry->txt().keys()) {
        QPair<QString, QString> txtRecord = qMakePair<QString, QString>(key, entry->txt().value(key));
        if (!sslEnabled && txtRecord.first == "sslEnabled") {
            sslEnabled = (txtRecord.second == "true");
        }
        if (txtRecord.first == "uuid") {
            uuid = QUuid(txtRecord.second);
        }
        if (txtRecord.first == "name") {
            serverName = txtRecord.second;
        }
        if (txtRecord.first == "serverVersion") {
            version = txtRecord.second;
        }
    }
    qCDebug(dcZeroConf()) << "Service entry added" << serverName << uuid << sslEnabled;


    NymeaHost* host = m_nymeaHosts->find(uuid);
    if (!host) {
        host = new NymeaHost(m_nymeaHosts);
        host->setUuid(uuid);
        qCInfo(dcZeroConf()) << "Adding new host:" << serverName << uuid;
        m_nymeaHosts->addHost(host);
    }
    host->setName(serverName);
    host->setVersion(version);
    QUrl url;
    // NOTE: On linux this is "_jsonrpc._tcp" while on apple systems this is "_jsonrpc._tcp."
    if (entry->type().startsWith("_jsonrpc._tcp")) {
        url.setScheme(sslEnabled ? "nymeas" : "nymea");
    } else if (entry->type().startsWith("_ws._tcp")) {
        url.setScheme(sslEnabled ? "wss" : "ws");
    }
    url.setHost(entry->ip().toString());
    url.setPort(entry->port());
    Connection *connection = host->connections()->find(url);
    if (!connection) {
        qCInfo(dcZeroConf()) << "Adding new connection to host:" << host->name() << url.toString();
        Connection::BearerType bearerType = QHostAddress(url.host()).isLoopback() ? Connection::BearerTypeLoopback : Connection::BearerTypeLan;
        connection = new Connection(url, bearerType, sslEnabled, "mDNS");
        connection->setOnline(true);
        host->connections()->addConnection(connection);
    } else {
        qCInfo(dcZeroConf()) << "Setting connection online:" << host->name() << url.toString();
        connection->setOnline(true);
    }
}

void ZeroconfDiscovery::serviceEntryRemoved(const QZeroConfService &entry)
{
    if (!entry->name().startsWith("nymea") || entry->ip().isNull()) {
        return;
    }

    QUuid uuid;
    bool sslEnabled = false;
    QString serverName;
    QString version;
    foreach (const QByteArray &key, entry->txt().keys()) {
        QPair<QString, QString> txtRecord = qMakePair<QString, QString>(key, entry->txt().value(key));
        if (!sslEnabled && txtRecord.first == "sslEnabled") {
            sslEnabled = (txtRecord.second == "true");
        }
        if (txtRecord.first == "uuid") {
            uuid = QUuid(txtRecord.second);
        }
        if (txtRecord.first == "name") {
            serverName = txtRecord.second;
        }
        if (txtRecord.first == "serverVersion") {
            version = txtRecord.second;
        }
    }

    qCDebug(dcZeroConf()) << "Service entry removed" << entry->name();

    NymeaHost* host = m_nymeaHosts->find(uuid);
    if (!host) {
        // Nothing to do...
        return;
    }

    QUrl url;
    if (entry->type() == "_jsonrpc._tcp") {
        url.setScheme(sslEnabled ? "nymeas" : "nymea");
    } else {
        url.setScheme(sslEnabled ? "wss" : "ws");
    }
    url.setHost(entry->ip().toString());
    url.setPort(entry->port());
    Connection *connection = host->connections()->find(url);
    if (!connection){
        // Connection url not found...
        return;
    }

    qCInfo(dcZeroConf()) << "Setting connection offline:" << host->name() << url.toString();
    connection->setOnline(false);
}
#endif
