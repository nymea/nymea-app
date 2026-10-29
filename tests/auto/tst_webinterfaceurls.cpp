// SPDX-License-Identifier: GPL-3.0-or-later

#include "configuration/serverconfiguration.h"

#include <QFile>
#include <QJSEngine>
#include <QScopedPointer>
#include <QSignalSpy>
#include <QtTest>

class TestWebInterfaceUrls : public QObject
{
    Q_OBJECT

private slots:
    void urls_data()
    {
        QTest::addColumn<QString>("configuration");
        QTest::addColumn<QString>("expected");
        QTest::newRow("old-server") << QString("{port:8080,sslEnabled:false}") << QString("http://192.168.1.10:8080/debug/");
        QTest::newRow("http-proxy") << QString("{port:8080,proxyPort:80,proxySslEnabled:false}") << QString("http://192.168.1.10/debug/");
        QTest::newRow("https-prefix") << QString("{proxyPort:443,proxySslEnabled:true,proxyPathPrefix:'/nymea'}") << QString("https://192.168.1.10/nymea/debug/");
        QTest::newRow("custom-port") << QString("{proxyPort:8443,proxySslEnabled:true,proxyPathPrefix:'/nymea'}") << QString("https://192.168.1.10:8443/nymea/debug/");
        QTest::newRow("direct-https") << QString("{port:443,sslEnabled:true,proxyPort:0}") << QString("https://192.168.1.10/debug/");
    }

    void urls()
    {
        QFETCH(QString, configuration);
        QFETCH(QString, expected);
        QJSEngine engine;
        QVERIFY(loadHelper(engine));
        QCOMPARE(engine.evaluate("interfaceUrl('192.168.1.10', " + configuration + ", 'debug')").toString(), expected);
        QCOMPARE(engine.evaluate("interfaceUrl('192.168.1.10', " + configuration + ", 'evdash')").toString(), QString(expected).replace("/debug/", "/evdash/"));
        QCOMPARE(engine.evaluate("interfaceUrl('', " + configuration + ", 'debug')").toString(), QString());
        QCOMPARE(engine.evaluate("interfaceUrl('192.168.1.10', null, 'debug')").toString(), QString());
    }

    void interfaceAddress()
    {
        QJSEngine engine;
        QVERIFY(loadHelper(engine));
        QVERIFY(!engine.evaluate(R"(
            var interfaces = [];
            var model = {get:function(i) { return interfaces[i]; }};
            function pick() { model.count = interfaces.length; return interfaceAddress(model); }
            function iface(kind, state, addresses) {
                return {kind:kind, operationalState:state, ipv4Addresses:addresses.map(function(a) { return {address:a, prefixLength:24}; })};
            }
        )").isError());
        QCOMPARE(engine.evaluate("pick()").toString(), QString());
        QCOMPARE(engine.evaluate("interfaceAddress(null)").toString(), QString());

        engine.evaluate("interfaces = [iface('loopback','up',['127.0.0.1']), iface('bridge','up',['10.0.3.1']), iface('wifi','up',['192.168.1.20'])]");
        QCOMPARE(engine.evaluate("pick()").toString(), QString("192.168.1.20"));

        engine.evaluate("interfaces.push(iface('ethernet','routable',['169.254.1.2','192.168.1.10']))");
        QCOMPARE(engine.evaluate("pick()").toString(), QString("192.168.1.10"));

        engine.evaluate("interfaces[3].operationalState = 'no-carrier'");
        QCOMPARE(engine.evaluate("pick()").toString(), QString("192.168.1.20"));

        engine.evaluate("interfaces = [iface('ethernet','up',[]), iface('unknown','up',['172.17.0.1'])]");
        QCOMPARE(engine.evaluate("pick()").toString(), QString("172.17.0.1"));

        engine.evaluate("interfaces = [iface('loopback','up',['127.0.0.1'])]");
        QCOMPARE(engine.evaluate("pick()").toString(), QString());
    }

    void ipv4Address()
    {
        QJSEngine engine;
        QVERIFY(loadHelper(engine));
        QVERIFY(engine.evaluate("isIpv4Address('192.168.1.10')").toBool());
        QVERIFY(engine.evaluate("isIpv4Address('127.0.0.1')").toBool());
        QVERIFY(!engine.evaluate("isIpv4Address('256.1.1.1')").toBool());
        QVERIFY(!engine.evaluate("isIpv4Address('nymea.local')").toBool());
        QVERIFY(!engine.evaluate("isIpv4Address('fe80::1')").toBool());
        QVERIFY(!engine.evaluate("isIpv4Address('')").toBool());
        QVERIFY(!engine.evaluate("isIpv4Address(undefined)").toBool());
    }

    void selection()
    {
        QJSEngine engine;
        QVERIFY(loadHelper(engine));
        QVERIFY(!engine.evaluate(R"(
            var entries = [
                {id:'wild',address:'0.0.0.0',sslEnabled:false},
                {id:'exact',address:'192.168.1.10',sslEnabled:true},
                {id:'local',address:'127.0.0.1',sslEnabled:false}
            ];
            var model = {get:function(i) { return entries[i]; }};
            function select(address) { model.count = entries.length; return selectConfiguration(model, address); }
        )").isError());
        QCOMPARE(engine.evaluate("select('192.168.1.10').id").toString(), QString("exact"));
        QCOMPARE(engine.evaluate("select('192.168.1.11').id").toString(), QString("wild"));
        QVERIFY(engine.evaluate("select('') === null").toBool());
        engine.evaluate("entries.push({id:'z-proxy',address:'127.0.0.1',proxyPort:443})");
        QCOMPARE(engine.evaluate("select('192.168.1.10').id").toString(), QString("z-proxy"));
        engine.evaluate("entries.push({id:'a-proxy',address:'127.0.0.1',proxyPort:80})");
        QCOMPARE(engine.evaluate("select('192.168.1.10').id").toString(), QString("a-proxy"));
        engine.evaluate("entries = [{id:'local',address:'127.0.0.1'}]");
        QVERIFY(engine.evaluate("select('192.168.1.10') === null").toBool());
    }

    void modelNotificationsAndClone()
    {
        WebServerConfiguration config("local", "127.0.0.1", 8080);
        QSignalSpy spy(&config, &WebServerConfiguration::proxySettingsChanged);
        QCOMPARE(config.proxyPort(), 0);
        QVERIFY(!config.proxySslEnabled());
        QVERIFY(config.proxyPathPrefix().isEmpty());
        config.setProxySettings(443, true, "/nymea");
        QCOMPARE(spy.count(), 1);
        config.setProxySettings(443, true, "/nymea");
        QCOMPARE(spy.count(), 1);
        QScopedPointer<ServerConfiguration> copy(config.clone());
        WebServerConfiguration *webCopy = qobject_cast<WebServerConfiguration *>(copy.data());
        QVERIFY(webCopy);
        QCOMPARE(webCopy->proxyPort(), 443);
        QVERIFY(webCopy->proxySslEnabled());
        QCOMPARE(webCopy->proxyPathPrefix(), QString("/nymea"));
        config.setProxySettings(0, false, QString());
        QCOMPARE(spy.count(), 2);
        QCOMPARE(webCopy->proxyPort(), 443);
    }

private:
    bool loadHelper(QJSEngine &engine)
    {
        QFile file(QStringLiteral(WEB_INTERFACE_URLS_SOURCE));
        if (!file.open(QIODevice::ReadOnly))
            return false;
        QString source = QString::fromUtf8(file.readAll());
        source.remove(".pragma library");
        return !engine.evaluate(source, file.fileName()).isError();
    }
};

QTEST_GUILESS_MAIN(TestWebInterfaceUrls)
#include "tst_webinterfaceurls.moc"
