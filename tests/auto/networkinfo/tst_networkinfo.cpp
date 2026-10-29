// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2024 - 2026, chargebyte austria GmbH
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
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include <QSignalSpy>
#include <QtTest>

#include "configuration/networkinfo.h"
#include "configuration/networkinterfaces.h"
#include "configuration/networkinterfacesproxy.h"

static QVariantMap address(const QString &ip, int prefixLength)
{
    return {{"address", ip}, {"prefixLength", prefixLength}};
}

static QVariantMap networkInterface(int index, const QString &name, const QString &kind, const QVariantList &ipv4 = QVariantList(), const QVariantList &ipv6 = QVariantList())
{
    return {
        {"index", index},
        {"name", name},
        {"kind", kind},
        {"macAddress", index == 1 ? QString() : QString("00:11:22:33:44:%1").arg(index, 2, 10, QChar('0'))},
        {"administrativeState", "up"},
        {"operationalState", "up"},
        {"managementStatus", "managed"},
        {"ipv4Addresses", ipv4},
        {"ipv6Addresses", ipv6}
    };
}

static QStringList names(NetworkInterfaces *model)
{
    QStringList result;
    for (int i = 0; i < model->rowCount(); i++) {
        result.append(model->get(i).value("name").toString());
    }
    return result;
}

static QVariantMap backendInfo(const QString &backend, bool available)
{
    return {{"backendInfo", QVariantMap {{"backend", backend}, {"available", available}, {"features", QStringList {"interfaceReporting"}}}}};
}

class TestNetworkInfo : public QObject
{
    Q_OBJECT

private slots:
    void shouldOrderSnapshotByInterfaceIndex()
    {
        NetworkInterfaces model;
        model.applySnapshot({networkInterface(3, "wlan0", "wifi"), networkInterface(1, "lo", "loopback"), networkInterface(2, "eth0", "ethernet")});
        QCOMPARE(names(&model), QStringList({"lo", "eth0", "wlan0"}));
    }

    void shouldNormalizeMissingFields()
    {
        NetworkInterfaces model;
        model.applySnapshot({QVariantMap {{"index", 4}, {"name", "br0"}}, QVariantMap {{"index", 5}}});
        QCOMPARE(model.rowCount(), 1);
        const QVariantMap entry = model.get(0);
        QCOMPARE(entry.value("kind").toString(), QString("unknown"));
        QCOMPARE(entry.value("managementStatus").toString(), QString("unknown"));
        QCOMPARE(entry.value("operationalState").toString(), QString("unknown"));
        QVERIFY(entry.value("macAddress").toString().isEmpty());
        QVERIFY(entry.value("ipv4Addresses").toList().isEmpty());
        QVERIFY(entry.value("ipv6Addresses").toList().isEmpty());
    }

    void shouldKeepUnchangedRowsOnIdenticalSnapshot()
    {
        NetworkInterfaces model;
        const QVariantList snapshot = {networkInterface(1, "lo", "loopback"), networkInterface(2, "eth0", "ethernet", {address("10.0.0.2", 24)})};
        model.applySnapshot(snapshot);

        QSignalSpy inserted(&model, &NetworkInterfaces::rowsInserted);
        QSignalSpy removed(&model, &NetworkInterfaces::rowsRemoved);
        QSignalSpy changed(&model, &NetworkInterfaces::dataChanged);
        QSignalSpy reset(&model, &NetworkInterfaces::modelReset);
        model.applySnapshot(snapshot);
        QCOMPARE(inserted.count() + removed.count() + changed.count() + reset.count(), 0);
    }

    void shouldUpdateAddressChangesInPlace()
    {
        NetworkInterfaces model;
        model.applySnapshot({networkInterface(1, "lo", "loopback"), networkInterface(2, "eth0", "ethernet", {address("10.0.0.2", 24)})});

        QSignalSpy inserted(&model, &NetworkInterfaces::rowsInserted);
        QSignalSpy removed(&model, &NetworkInterfaces::rowsRemoved);
        QSignalSpy changed(&model, &NetworkInterfaces::dataChanged);
        model.applySnapshot({networkInterface(1, "lo", "loopback"), networkInterface(2, "eth0", "ethernet", {address("10.0.0.3", 16)}, {address("fe80::1", 64)})});

        QCOMPARE(inserted.count(), 0);
        QCOMPARE(removed.count(), 0);
        QCOMPARE(changed.count(), 1);
        QCOMPARE(changed.first().at(0).toModelIndex().row(), 1);
        QCOMPARE(model.get(1).value("ipv4Addresses").toList().first().toMap().value("address").toString(), QString("10.0.0.3"));
        QCOMPARE(model.get(1).value("ipv4Addresses").toList().first().toMap().value("prefixLength").toInt(), 16);
        QCOMPARE(model.get(1).value("ipv6Addresses").toList().count(), 1);
    }

    void shouldTreatRenameAsUpdate()
    {
        NetworkInterfaces model;
        model.applySnapshot({networkInterface(2, "eth0", "ethernet")});

        QSignalSpy inserted(&model, &NetworkInterfaces::rowsInserted);
        QSignalSpy removed(&model, &NetworkInterfaces::rowsRemoved);
        QSignalSpy changed(&model, &NetworkInterfaces::dataChanged);
        model.applySnapshot({networkInterface(2, "enp1s0", "ethernet")});

        QCOMPARE(inserted.count(), 0);
        QCOMPARE(removed.count(), 0);
        QCOMPARE(changed.count(), 1);
        QCOMPARE(names(&model), QStringList({"enp1s0"}));
    }

    void shouldInsertAndRemoveSingleRows()
    {
        NetworkInterfaces model;
        model.applySnapshot({networkInterface(1, "lo", "loopback"), networkInterface(5, "wlan0", "wifi")});

        QSignalSpy inserted(&model, &NetworkInterfaces::rowsInserted);
        QSignalSpy countChanged(&model, &NetworkInterfaces::countChanged);
        model.applySnapshot({networkInterface(1, "lo", "loopback"), networkInterface(3, "br0", "bridge"), networkInterface(4, "eth0.10", "vlan"), networkInterface(5, "wlan0", "wifi")});
        QCOMPARE(names(&model), QStringList({"lo", "br0", "eth0.10", "wlan0"}));
        QCOMPARE(inserted.count(), 2);
        QCOMPARE(inserted.at(0).at(1).toInt(), 1);
        QCOMPARE(inserted.at(1).at(1).toInt(), 2);
        QCOMPARE(countChanged.count(), 1);

        QSignalSpy removed(&model, &NetworkInterfaces::rowsRemoved);
        model.applySnapshot({networkInterface(3, "br0", "bridge"), networkInterface(5, "wlan0", "wifi")});
        QCOMPARE(names(&model), QStringList({"br0", "wlan0"}));
        QCOMPARE(removed.count(), 2);

        model.applySnapshot(QVariantList());
        QCOMPARE(model.rowCount(), 0);
    }

    void shouldHideFilteredKinds()
    {
        NetworkInterfaces model;
        model.applySnapshot({networkInterface(1, "lo", "loopback"), networkInterface(2, "eth0", "ethernet"), networkInterface(3, "br0", "bridge"),
                             networkInterface(4, "veth0", "unknown"), networkInterface(5, "tun0", "tun")});

        NetworkInterfacesProxy proxy;
        proxy.setNetworkInterfaces(&model);
        QCOMPARE(proxy.rowCount(), 5);

        QSignalSpy countChanged(&proxy, &NetworkInterfacesProxy::countChanged);
        proxy.setHiddenKinds({"loopback", "bridge", "unknown"});
        QVERIFY(countChanged.count() > 0);
        QCOMPARE(proxy.rowCount(), 2);
        QCOMPARE(proxy.get(0).value("name").toString(), QString("eth0"));
        QCOMPARE(proxy.get(1).value("name").toString(), QString("tun0"));

        // Snapshot updates pass through the filter
        model.applySnapshot({networkInterface(1, "lo", "loopback"), networkInterface(2, "eth0", "ethernet"), networkInterface(6, "wlan0", "wifi")});
        QCOMPARE(proxy.rowCount(), 2);
        QCOMPARE(proxy.get(1).value("name").toString(), QString("wlan0"));

        proxy.setHiddenKinds(QStringList());
        QCOMPARE(proxy.rowCount(), 3);
    }

    void shouldFollowSourceModelLifetime()
    {
        NetworkInterfacesProxy proxy;
        proxy.setHiddenKinds({"loopback"});
        {
            NetworkInterfaces model;
            model.applySnapshot({networkInterface(1, "lo", "loopback"), networkInterface(2, "eth0", "ethernet")});
            proxy.setSourceModel(&model);
            QCOMPARE(proxy.networkInterfaces(), &model);
            QCOMPARE(proxy.rowCount(), 1);
            QCOMPARE(proxy.get(0).value("name").toString(), QString("eth0"));
        }
        QVERIFY(!proxy.networkInterfaces());
        QCOMPARE(proxy.rowCount(), 0);
        QVERIFY(proxy.get(0).isEmpty());
    }

    void shouldNotRequestWhileDisconnected()
    {
        Engine engine;
        NetworkInfo info;
        info.setEngine(&engine);
        QCOMPARE(engine.jsonRpcClient()->m_nameSpace, QString("Network"));
        QVERIFY(engine.jsonRpcClient()->m_requests.isEmpty());
        QVERIFY(!info.loading());
        QVERIFY(!info.supported());
    }

    void shouldLoadBackendInfoAndSnapshotOnConnect()
    {
        Engine engine;
        JsonRpcClient *client = engine.jsonRpcClient();
        NetworkInfo info;
        info.setEngine(&engine);
        client->setConnected(true);

        QVERIFY(info.loading());
        QCOMPARE(client->m_requests.count(), 1);
        QCOMPARE(client->m_requests.last().method, QString("Network.GetBackendInfo"));

        client->reply(client->m_requests.last(), backendInfo("networkd", true));
        QVERIFY(info.supported());
        QVERIFY(info.loading());
        QCOMPARE(info.backend(), QString("networkd"));
        QVERIFY(info.backendAvailable());
        QCOMPARE(info.features(), QStringList({"interfaceReporting"}));
        QCOMPARE(client->m_requests.last().method, QString("Network.GetInterfaces"));

        client->reply(client->m_requests.last(), {{"interfaces", QVariantList {networkInterface(1, "lo", "loopback"), networkInterface(2, "eth0", "ethernet")}}});
        QVERIFY(!info.loading());
        QCOMPARE(names(info.interfaces()), QStringList({"lo", "eth0"}));
    }

    void shouldFallBackOnOlderServers()
    {
        Engine engine;
        JsonRpcClient *client = engine.jsonRpcClient();
        NetworkInfo info;
        info.setEngine(&engine);
        client->setConnected(true);

        // An unknown method yields an error reply with empty params
        client->reply(client->m_requests.last(), QVariantMap());
        QVERIFY(!info.supported());
        QVERIFY(!info.loading());
        QCOMPARE(client->m_requests.count(), 1);
        QCOMPARE(info.interfaces()->rowCount(), 0);
    }

    void shouldApplyNotificationsAsFullSnapshots()
    {
        Engine engine;
        JsonRpcClient *client = engine.jsonRpcClient();
        NetworkInfo info;
        info.setEngine(&engine);
        client->setConnected(true);
        client->reply(client->m_requests.last(), backendInfo("none", false));
        client->reply(client->m_requests.last(), {{"interfaces", QVariantList {networkInterface(1, "lo", "loopback"), networkInterface(2, "eth0", "ethernet")}}});

        QSignalSpy backendSpy(&info, &NetworkInfo::backendInfoChanged);
        client->notify("Network.BackendInfoChanged", backendInfo("networkmanager", true));
        QCOMPARE(backendSpy.count(), 1);
        QCOMPARE(info.backend(), QString("networkmanager"));
        QVERIFY(info.backendAvailable());

        client->notify("Network.InterfacesChanged", {{"interfaces", QVariantList {networkInterface(2, "eth0", "ethernet"), networkInterface(7, "wlan0", "wifi")}}});
        QCOMPARE(names(info.interfaces()), QStringList({"eth0", "wlan0"}));
    }

    void shouldClearAndRefetchOnReconnect()
    {
        Engine engine;
        JsonRpcClient *client = engine.jsonRpcClient();
        NetworkInfo info;
        info.setEngine(&engine);
        client->setConnected(true);
        client->reply(client->m_requests.last(), backendInfo("networkd", true));
        const JsonRpcClient::Request staleInterfacesRequest = client->m_requests.last();

        client->setConnected(false);
        QVERIFY(!info.supported());
        QVERIFY(!info.loading());
        QVERIFY(info.backend().isEmpty());
        QCOMPARE(info.interfaces()->rowCount(), 0);

        // A reply belonging to the previous connection must not resurrect stale rows
        client->reply(staleInterfacesRequest, {{"interfaces", QVariantList {networkInterface(2, "eth0", "ethernet")}}});
        QCOMPARE(info.interfaces()->rowCount(), 0);

        client->setConnected(true);
        QVERIFY(info.loading());
        QCOMPARE(client->m_requests.last().method, QString("Network.GetBackendInfo"));
        client->reply(client->m_requests.last(), backendInfo("networkmanager", true));
        client->reply(client->m_requests.last(), {{"interfaces", QVariantList {networkInterface(3, "wlan0", "wifi")}}});
        QCOMPARE(info.backend(), QString("networkmanager"));
        QCOMPARE(names(info.interfaces()), QStringList({"wlan0"}));
    }

    void shouldNotReportLegacyStateWhileReloading()
    {
        Engine engine;
        JsonRpcClient *client = engine.jsonRpcClient();
        NetworkInfo info;
        info.setEngine(&engine);
        client->setConnected(true);
        client->reply(client->m_requests.last(), backendInfo("networkd", true));
        client->reply(client->m_requests.last(), {{"interfaces", QVariantList {networkInterface(2, "eth0", "ethernet")}}});
        QVERIFY(info.supported());

        // The page shows the legacy sections for !loading && !supported
        bool legacyShown = false;
        auto check = [&]() { legacyShown |= !info.loading() && !info.supported(); };
        connect(&info, &NetworkInfo::loadingChanged, this, check);
        connect(&info, &NetworkInfo::supportedChanged, this, check);
        client->setConnected(true);
        QVERIFY(info.loading());
        QVERIFY(!legacyShown);
    }

    void shouldSurviveEngineDeletion()
    {
        NetworkInfo info;
        Engine *engine = new Engine;
        info.setEngine(engine);
        engine->jsonRpcClient()->setConnected(true);
        delete engine;
        QVERIFY(!info.engine());
    }
};

QTEST_GUILESS_MAIN(TestNetworkInfo)
#include "tst_networkinfo.moc"
