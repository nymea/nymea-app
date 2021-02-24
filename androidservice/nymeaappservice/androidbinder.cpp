#include "androidbinder.h"
#include "engine.h"
#include "types/thing.h"

#include <QDebug>
#include <QAndroidParcel>
#include <QAndroidJniObject>
#include <QJsonDocument>
#include <QtAndroid>

AndroidBinder::AndroidBinder(NymeaAppService *service):
    m_service(service)
{
}

bool AndroidBinder::onTransact(int code, const QAndroidParcel &data, const QAndroidParcel &reply, QAndroidBinder::CallType flags)
{
    qDebug() << "onTransact: code " << code << ", flags " << int(flags);

//    QString payload = data.readData();
    QString payload = data.handle().callObjectMethod<jstring>("readString").toString();

    QJsonParseError error;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(payload.toUtf8(), &error);
    if (error.error != QJsonParseError::NoError) {
        qWarning() << "Error parsing JSON from parcel:" << error.errorString();
        qWarning() << payload;
        return false;
    }
    QVariantMap request = jsonDoc.toVariant().toMap();

    if (request.value("method").toString() == "GetInstances") {
        QVariantMap params;
        QVariantList instances;
        foreach (const QUuid &nymeaId, m_service->engines().keys()) {
            Engine *engine = m_service->engines().value(nymeaId);
            QVariantMap instance;
            instance.insert("id", nymeaId);
            instance.insert("isReady", engine->jsonRpcClient()->connected() && !engine->thingManager()->fetchingData());
            instance.insert("name", engine->jsonRpcClient()->currentHost()->name());
            instances.append(instance);
        }
        params.insert("instances", instances);
        sendReply(reply, params);
        return true;
    }

    if (request.value("method").toString() == "GetThings") {
        QUuid nymeaId = request.value("params").toMap().value("nymeaId").toUuid();
        Engine *engine = m_service->engines().value(nymeaId);
        if (!engine) {
            qWarning() << "Android client requested things for an invalid nymea instance:" << nymeaId;
            return false;
        }
        QVariantList thingsList;
        for (int i = 0; i < engine->thingManager()->things()->rowCount(); i++) {
            Device *thing = engine->thingManager()->things()->get(i);
            QVariantMap thingMap;
            thingMap.insert("id", thing->id());
            thingMap.insert("name", thing->name());
            thingMap.insert("className", thing->thingClass()->displayName());
            thingMap.insert("interfaces", thing->thingClass()->interfaces());
            QVariantList states;
            for (int j = 0; j < thing->states()->rowCount(); j++) {
                State *state = thing->states()->get(j);
                QVariantMap stateMap;
                stateMap.insert("stateTypeId", state->stateTypeId());
                stateMap.insert("name", thing->thingClass()->stateTypes()->getStateType(state->stateTypeId())->name());
                stateMap.insert("displayName", thing->thingClass()->stateTypes()->getStateType(state->stateTypeId())->displayName());
                stateMap.insert("value", state->value());
                states.append(stateMap);
            }
            thingMap.insert("states", states);
            QVariantList actions;
            for (int j = 0; j < thing->thingClass()->actionTypes()->rowCount(); j++) {
                ActionType *actionType = thing->thingClass()->actionTypes()->get(j);
                QVariantMap actionMap;
                actionMap.insert("actionTypeId", actionType->id());
                actionMap.insert("name", actionType->name());
                actionMap.insert("displayName", actionType->displayName());
                actions.append(actionMap);
            }
            thingMap.insert("actions", actions);
            thingsList.append(thingMap);
        }
        QVariantMap params;
        params.insert("things", thingsList);
        sendReply(reply, params);
        return true;
    }

    if (request.value("method").toString() == "ExecuteAction") {
        qDebug() << "ExecuteAction";
        QUuid nymeaId = request.value("params").toMap().value("nymeaId").toUuid();
        Engine *engine = m_service->engines().value(nymeaId);
        if (!engine) {
            qWarning() << "Android client requested executeAction for an invalid nymea instance:" << nymeaId;
            return false;
        }
        QUuid thingId = request.value("params").toMap().value("thingId").toUuid();
        QUuid actionTypeId = request.value("params").toMap().value("actionTypeId").toUuid();
        QVariantList params = request.value("params").toMap().value("params").toList();

        qDebug() << "**** executeAction:" << thingId << actionTypeId << params;
        engine->thingManager()->executeAction(thingId, actionTypeId, params);
    }

    return false;
}

void AndroidBinder::sendReply(const QAndroidParcel &reply, const QVariantMap &params)
{
    QString payload = QJsonDocument::fromVariant(params).toJson();
    reply.handle().callMethod<void>("writeString", "(Ljava/lang/String;)V", QAndroidJniObject::fromString(payload).object<jstring>());
}
