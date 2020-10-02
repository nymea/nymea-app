#include "devicecontrolapplication.h"

#include "engine.h"
#include "connection/discovery/nymeadiscovery.h"
#include "connection/nymeahosts.h"
#include "libnymea-app-core.h"
#include "../nymea-app/stylecontroller.h"
#include "../nymea-app/platformhelper.h"
#include "../nymea-app/nfchelper.h"
#include "../nymea-app/platformintegration/android/platformhelperandroid.h"

#include <QQmlApplicationEngine>
#include <QtDebug>
#include <QtQml>
#include <QtAndroid>
#include <QAndroidJniObject>
#include <QNdefNfcUriRecord>

QObject *platformHelperProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return new PlatformHelperAndroid();
}

DeviceControlApplication::DeviceControlApplication(int argc, char *argv[]) : QApplication(argc, argv)
{
    setApplicationName("nymea-app");
    setOrganizationName("nymea");

    QNearFieldManager *manager = new QNearFieldManager(this);
    int ret = manager->registerNdefMessageHandler(this, SLOT(handleNdefMessage(QNdefMessage,QNearFieldTarget*)));
    qDebug() << "*** NFC registered" << ret;

    QString nymeaId = QtAndroid::androidActivity().callObjectMethod<jstring>("nymeaId").toString();
    QString thingId = QtAndroid::androidActivity().callObjectMethod<jstring>("thingId").toString();

    QSettings settings;

    m_discovery = new NymeaDiscovery(this);
    AWSClient::instance()->setConfig(settings.value("cloudEnvironment").toString());
    m_discovery->setAwsClient(AWSClient::instance());
    NymeaHost *host = m_discovery->nymeaHosts()->find(nymeaId);

    if (nymeaId.isEmpty() && !host) {
        qWarning() << "No such nymea host:" << nymeaId;
        // TODO: We could wait here until the discovery finds it... But it really should be cached already...
        exit(1);
    }

    m_engine = new Engine(this);

    m_engine->jsonRpcClient()->connectToHost(host);

    qDebug() << "Connecting to:" << host;

    qDebug() << "Creating QML view";
    m_qmlEngine = new QQmlApplicationEngine(this);

    registerQmlTypes();

    qmlRegisterSingletonType<PlatformHelper>("Nymea", 1, 0, "PlatformHelper", platformHelperProvider);
    qmlRegisterSingletonType(QUrl("qrc:///ui/utils/NymeaUtils.qml"), "Nymea", 1, 0, "NymeaUtils" );
    qmlRegisterType<NfcHelper>("Nymea", 1, 0, "NfcHelper");

    StyleController styleController;
    m_qmlEngine->rootContext()->setContextProperty("styleController", &styleController);
    m_qmlEngine->rootContext()->setContextProperty("engine", m_engine);
    m_qmlEngine->rootContext()->setContextProperty("_engine", m_engine);
    m_qmlEngine->rootContext()->setContextProperty("controlledThingId", thingId);

    m_qmlEngine->load(QUrl(QLatin1String("qrc:/Main.qml")));
}

void DeviceControlApplication::handleNdefMessage(QNdefMessage message, QNearFieldTarget *target)
{
    qDebug() << "************* NFC message!" << message.toByteArray() << target;
    foreach (const QNdefRecord &record, message) {
        QNdefNfcUriRecord uriRecord(record);
        qDebug() << "record" << uriRecord.uri();
        QUrl url = uriRecord.uri();
        QUuid nymeaId = QUuid(url.host().split('.').first());
        QUuid thingId = QUuid(url.host().split('.').last());
        QList<QPair<QString, QString>> queryItems = QUrlQuery(url.query()).queryItems();
        for (int i = 0; i < queryItems.count(); i++) {
            QUuid stateTypeId = queryItems.at(i).first;
            QVariant value = queryItems.at(i).second;

        }

        NymeaHost *host = m_discovery->nymeaHosts()->find(nymeaId);
        m_engine->jsonRpcClient()->connectToHost(host);
        m_qmlEngine->rootContext()->setContextProperty("controlledThingId", thingId);
    }
}

void DeviceControlApplication::createView()
{

}


