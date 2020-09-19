#include "nymeaappservice.h"
#include "androidbinder.h"

#include <QtAndroid>
#include <QDebug>
#include <QSettings>
#include <QJsonDocument>

#include "connection/discovery/nymeadiscovery.h"
#include "connection/nymeahosts.h"

NymeaAppService::NymeaAppService(int argc, char **argv):
    QAndroidService(argc, argv, [=](const QAndroidIntent &) {
        return new AndroidBinder{m_engine};
    })
{
    setApplicationName("nymea-app");
    setOrganizationName("nymea");

    m_engine = new Engine(this);

    QSettings settings;
    settings.beginGroup("tabSettings0");
    QUuid lastConnected = settings.value("lastConnectedHost").toUuid();
    settings.endGroup();

    NymeaDiscovery *discovery = new NymeaDiscovery(this);
    AWSClient::instance()->setConfig(settings.value("cloudEnvironment").toString());
    discovery->setAwsClient(AWSClient::instance());

    NymeaHost *host = discovery->nymeaHosts()->find(lastConnected);
    if (host) {
        m_engine->jsonRpcClient()->connectToHost(host);
    }

    QObject::connect(m_engine->thingManager(), &DeviceManager::thingStateChanged, [=](const QUuid &thingId, const QUuid &stateTypeId, const QVariant &value){
        QVariantMap params;
        params.insert("thingId", thingId);
        params.insert("stateTypeId", stateTypeId);
        params.insert("value", value);
        sendNotification("ThingStateChanged", params);
    });

    connect(m_engine->thingManager(), &DeviceManager::fetchingDataChanged, [=]() {
        QVariantMap params;
        params.insert("isReady", !m_engine->thingManager()->fetchingData());
        if (m_engine->jsonRpcClient()->connected()) {
            params.insert("systemName", m_engine->jsonRpcClient()->currentHost()->name());
        }
        sendNotification("ReadyStateChanged", params);
    });
}

void NymeaAppService::sendNotification(const QString &notification, const QVariantMap &params)
{
    QVariantMap data;
    data.insert("notification", notification);
    data.insert("params", params);
    QString payload = QJsonDocument::fromVariant(data).toJson();
    QtAndroid::androidService().callMethod<void>("sendBroadcast",
                                                 "(Ljava/lang/String;)V",
                                                 QAndroidJniObject::fromString(payload).object<jstring>());

}
