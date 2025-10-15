#include "nymeaappservice.h"
#include "androidbinder.h"

#include <QDebug>
#include <QJniObject>
#include <QJsonDocument>
#include <QNativeInterface>
#include <QSettings>
#include <QVariantMap>

#include <jni.h>

#include "connection/discovery/nymeadiscovery.h"
#include "connection/nymeahosts.h"

NymeaAppService::NymeaAppService(int argc, char **argv):
    QCoreApplication(argc, argv),
    m_binder(this)
{
    s_instance = this;
    setApplicationName("nymea-app");
    setOrganizationName("nymea");

    QSettings settings;

    NymeaDiscovery *discovery = new NymeaDiscovery(this);

    settings.beginGroup("ConfiguredHosts");
    foreach (const QString &childGroup, settings.childGroups()) {
        settings.beginGroup(childGroup);
        QUuid lastConnected = settings.value("uuid").toUuid();
        QString cachedName = settings.value("cachedName").toString();
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
    settings.endGroup();

    qDebug() << "NymeaAppService started.";

}

NymeaAppService::~NymeaAppService()
{
    if (s_instance == this) {
        s_instance = nullptr;
    }
}

NymeaAppService *NymeaAppService::s_instance = nullptr;

QHash<QUuid, Engine *> NymeaAppService::engines() const
{
    return m_engines;
}

QString NymeaAppService::handleBinderRequest(const QString &payload)
{
    bool handled = false;
    QString reply = m_binder.handleTransact(payload, &handled);
    if (!handled) {
        qWarning() << "Unhandled binder payload" << payload;
        return {};
    }
    return reply;
}

NymeaAppService *NymeaAppService::instance()
{
    return s_instance;
}

void NymeaAppService::sendNotification(const QString &notification, const QVariantMap &params)
{
    QVariantMap data;
    data.insert("notification", notification);
    data.insert("params", params);
    QString payload = QJsonDocument::fromVariant(data).toJson();
    QNativeInterface::QAndroidApplication::service().callMethod<void>("sendBroadcast",
                                                                     "(Ljava/lang/String;)V",
                                                                     QJniObject::fromString(payload).object<jstring>());

}

extern "C" JNIEXPORT jstring JNICALL
Java_io_guh_nymeaapp_NymeaAppService_handleBinderRequest(JNIEnv *env, jclass /*clazz*/, jstring request)
{
    Q_UNUSED(env);
    QString payload = QJniObject(request).toString();
    QString reply;
    if (NymeaAppService::instance()) {
        reply = NymeaAppService::instance()->handleBinderRequest(payload);
    } else {
        qWarning() << "NymeaAppService native instance not available for binder request";
    }

    return QJniObject::fromString(reply).object<jstring>();
}
