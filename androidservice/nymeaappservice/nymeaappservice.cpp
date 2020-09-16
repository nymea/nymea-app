#include "nymeaappservice.h"
#include "androidbinder.h"

#include <QtAndroid>
#include <QDebug>
#include <QSettings>

#include "connection/discovery/nymeadiscovery.h"
#include "connection/nymeahosts.h"

NymeaAppService::NymeaAppService(int argc, char **argv):
    QAndroidService(argc, argv, [=](const QAndroidIntent &) {
        qDebug() << "Android service onBind()";
        return new AndroidBinder{m_engine};
    }),
    m_engine(new Engine(this))
{
    setApplicationName("nymea-app");
    setOrganizationName("nymea");

    QSettings settings;
    settings.beginGroup("tabSettings0");
    QUuid lastConnected = settings.value("lastConnectedHost").toUuid();
    settings.endGroup();

    NymeaDiscovery *discovery = new NymeaDiscovery();

    NymeaHost *host = discovery->nymeaHosts()->find(lastConnected);
    qDebug() << "**** Tab settings" << lastConnected << host;
    if (host) {
        m_engine->jsonRpcClient()->connectToHost(host);
    }

    QObject::connect(m_engine->thingManager(), &DeviceManager::thingStateChanged, [=](const QUuid &thingId, const QUuid &stateTypeId, const QVariant &value){
//        qDebug() << "**** State changed" << thingId << stateTypeId << value;
        QtAndroid::androidService().callMethod<void>("sendBroadcast", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",
                                                     QAndroidJniObject::fromString(thingId.toString()).object<jstring>(),
                                                     QAndroidJniObject::fromString(stateTypeId.toString()).object<jstring>(),
                                                     QAndroidJniObject::fromString(value.toString()).object<jstring>());
    });


}
