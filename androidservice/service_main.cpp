#include <QDebug>
#include <QAndroidService>
#include <QSettings>
#include <QCoreApplication>
#include <QtAndroid>

#include "androidbinder.h"

#include "engine.h"
#include "connection/discovery/nymeadiscovery.h"
#include "connection/nymeahosts.h"

int main(int argc, char *argv[])
{
    qWarning() << "Service starting from a separate .so file";


    Engine *engine = new Engine();
//    engine->jsonRpcClient()->connectToHost()


    QAndroidService app(argc, argv, [=](const QAndroidIntent &) {
        qDebug() << "Android service onBind()";
        return new AndroidBinder{engine};
    });

    app.setApplicationName("nymea-app");
    app.setOrganizationName("nymea");

    qDebug() << "Starting nymea app service";

    QSettings settings;
    settings.beginGroup("tabSettings0");
    QUuid lastConnected = settings.value("lastConnectedHost").toUuid();
    settings.endGroup();

    NymeaDiscovery *discovery = new NymeaDiscovery();

    NymeaHost *host = discovery->nymeaHosts()->find(lastConnected);
    qDebug() << "**** Tab settings" << lastConnected << host;
    if (host) {
        engine->jsonRpcClient()->connectToHost(host);
    }

    QObject::connect(engine->thingManager(), &DeviceManager::thingStateChanged, [=](const QUuid &thingId, const QUuid &stateTypeId, const QVariant &value){
        qDebug() << "**** State changed" << thingId << stateTypeId << value;
        qDebug() << "Sending broadcast";
        QtAndroid::androidService().callMethod<void>("sendBroadcast", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",
                                                     QAndroidJniObject::fromString(thingId.toString()).object<jstring>(),
                                                     QAndroidJniObject::fromString(stateTypeId.toString()).object<jstring>(),
                                                     QAndroidJniObject::fromString(value.toString()).object<jstring>());
    });

    return app.exec();
}
