#include "devicecontrolapplication.h"

#include "engine.h"
#include "connection/discovery/nymeadiscovery.h"
#include "connection/nymeahosts.h"
#include "libnymea-app-core.h"
#include "../nymea-app/stylecontroller.h"
#include "../nymea-app/platformhelper.h"
#include "../nymea-app/platformintegration/android/platformhelperandroid.h"

#include <QQmlApplicationEngine>
#include <QtDebug>
#include <QtQml>
#include <QtAndroid>
#include <QAndroidJniObject>

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

    qDebug() << "Creating QML view";
    QQmlApplicationEngine *qmlEngine = new QQmlApplicationEngine(this);

    Engine *m_engine = new Engine(this);

    QSettings settings;
    settings.beginGroup("tabSettings0");
    QUuid lastConnected = settings.value("lastConnectedHost").toUuid();
    settings.endGroup();

    NymeaDiscovery *discovery = new NymeaDiscovery(this);
    AWSClient::instance()->setConfig(settings.value("cloudEnvironment").toString());
    discovery->setAwsClient(AWSClient::instance());

    NymeaHost *host = discovery->nymeaHosts()->find(lastConnected);
    qDebug() << "**** Tab settings" << lastConnected << host;
    if (host) {
        m_engine->jsonRpcClient()->connectToHost(host);
    }

    QString thingId = QtAndroid::androidActivity().callObjectMethod<jstring>("thingId").toString();

    registerQmlTypes();

    qmlRegisterSingletonType<PlatformHelper>("Nymea", 1, 0, "PlatformHelper", platformHelperProvider);
    qmlRegisterSingletonType(QUrl("qrc:///ui/utils/NymeaUtils.qml"), "Nymea", 1, 0, "NymeaUtils" );

    StyleController styleController;
    qmlEngine->rootContext()->setContextProperty("styleController", &styleController);
    qmlEngine->rootContext()->setContextProperty("engine", m_engine);
    qmlEngine->rootContext()->setContextProperty("_engine", m_engine);
    qmlEngine->rootContext()->setContextProperty("controlledThingId", thingId);

    qmlEngine->load(QUrl(QLatin1String("qrc:/Main.qml")));
}

