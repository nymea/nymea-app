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
        return new AndroidBinder{this};
    })
{
    setApplicationName("nymea-app");
    setOrganizationName("nymea");

    QSettings settings;

    NymeaDiscovery *discovery = new NymeaDiscovery(this);
    AWSClient::instance()->setConfig(settings.value("cloudEnvironment").toString());
    discovery->setAwsClient(AWSClient::instance());


    for (int i = 0; i < 5; i++) {
        settings.beginGroup(QString("tabSettings%1").arg(i));
        QUuid lastConnected = settings.value("lastConnectedHost").toUuid();
        settings.endGroup();

        if (lastConnected.isNull()) {
            continue;
        }
        NymeaHost *host = discovery->nymeaHosts()->find(lastConnected);
        if (!host) {
            continue;
        }

        Engine *engine = new Engine(this);
        engine->jsonRpcClient()->connectToHost(host);
        m_engines.insert(host->uuid(), engine);


        QObject::connect(engine->thingManager(), &ThingManager::thingStateChanged, [=](const QUuid &thingId, const QUuid &stateTypeId, const QVariant &value){
            QVariantMap params;
            params.insert("nymeaId", engine->jsonRpcClient()->currentHost()->uuid());
            params.insert("thingId", thingId);
            params.insert("stateTypeId", stateTypeId);
            params.insert("value", value);
            sendNotification("ThingStateChanged", params);
        });

        connect(engine->thingManager(), &ThingManager::fetchingDataChanged, [=]() {
            qDebug() << "Fetching data changed";
            QVariantMap params;
            params.insert("nymeaId", engine->jsonRpcClient()->currentHost()->uuid());
            params.insert("isReady", !engine->thingManager()->fetchingData());
            qDebug() << "Nymea host is ready" << engine->jsonRpcClient()->currentHost()->uuid();
            sendNotification("ReadyStateChanged", params);
        });
    }

    qDebug() << "NymeaAppService started.";

}

QHash<QUuid, Engine *> NymeaAppService::engines() const
{
    return m_engines;
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
