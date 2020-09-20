#include "androidbinder.h"
#include "engine.h"
#include "types/device.h"

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

//    switch (code) {
//    case 0: { // Status request
//        bool isReady = m_engine->jsonRpcClient()->connected() && !m_engine->thingManager()->fetchingData();
//        isReady = false;
//        reply.handle().callMethod<void>("writeBoolean", "(Z)V", isReady);
//        if (isReady) {
//            reply.handle().callMethod<void>("writeString", "(Ljava/lang/String;)V", QAndroidJniObject::fromString(m_engine->jsonRpcClient()->currentHost()->name()).object<jstring>());
//        }
//    } break;
//    case 1: {// Things request
//        QVariantList thingsList;
//        for (int i = 0; i < m_engine->thingManager()->things()->rowCount(); i++) {
//            Device *thing = m_engine->thingManager()->things()->get(i);
//            QVariantMap thingMap;
//            thingMap.insert("id", thing->id());
//            thingMap.insert("name", thing->name());
//            thingMap.insert("className", thing->thingClass()->displayName());
//            thingMap.insert("interfaces", thing->thingClass()->interfaces());
//            QVariantList states;
//            for (int j = 0; j < thing->states()->rowCount(); j++) {
//                State *state = thing->states()->get(j);
//                QVariantMap stateMap;
//                stateMap.insert("stateTypeId", state->stateTypeId());
//                stateMap.insert("name", thing->thingClass()->stateTypes()->getStateType(state->stateTypeId())->name());
//                stateMap.insert("displayName", thing->thingClass()->stateTypes()->getStateType(state->stateTypeId())->displayName());
//                stateMap.insert("value", state->value());
//                states.append(stateMap);
//            }
//            thingMap.insert("states", states);
//            QVariantList actions;
//            for (int j = 0; j < thing->thingClass()->actionTypes()->rowCount(); j++) {
//                ActionType *actionType = thing->thingClass()->actionTypes()->get(j);
//                QVariantMap actionMap;
//                actionMap.insert("actionTypeId", actionType->id());
//                actionMap.insert("name", actionType->name());
//                actionMap.insert("displayName", actionType->displayName());
//                actions.append(actionMap);
//            }
//            thingMap.insert("actions", actions);
//            thingsList.append(thingMap);
//        }
//        QJsonDocument jsonDoc = QJsonDocument::fromVariant(thingsList);
//        reply.handle().callMethod<void>("writeString", "(Ljava/lang/String;)V",  QAndroidJniObject::fromString(jsonDoc.toJson()).object<jstring>());
//    } break;
//    case 2: {// ExecuteAction
////        QString thingId = data.handle().callMethod<QAndroidJniObject>("readString", "").toString();
////        jstring atId = data.handle().callMethod<jstring>("readString", "");
////        QString actionTypeId = QAndroidJniObject::fromLocalRef(atId).toString();
////        jstring p = data.handle().callMethod<jstring>("readString", "");
////        QString param = QAndroidJniObject::fromLocalRef(p).toString();
//        qDebug() << "ExecuteAction";
//        QString thingId = data.readData();
//        QString actionTypeId = data.readData();
//        QString param = data.readData();
//        qDebug() << "**** executeAction:" << thingId << actionTypeId << param;

//        // FIXME: Only works with state generated actions!
//        QVariantMap paramMap;
//        paramMap.insert("paramTypeId", actionTypeId);
//        paramMap.insert("value", param);
//        m_engine->thingManager()->executeAction(thingId, actionTypeId, {paramMap});

//    } break;
////    default:
////        QAndroidBinder binder = data.readBinder();

////        qDebug() << TAG << ": onTransact() received non-name data" << data.readVariant();
////        reply.writeVariant(QVariant("Cannot process this!"));

////        // send back message
////        QAndroidParcel sendData, replyData;
////        sendData.writeVariant(QVariant("Send me only names!"));
////        binder.transact(0, sendData, &replyData);
////        qDebug() << TAG << ": onTransact() received " << replyData.readData();

////        break;
//    }
    return false;
}

void AndroidBinder::sendReply(const QAndroidParcel &reply, const QVariantMap &params)
{
    QString payload = QJsonDocument::fromVariant(params).toJson();
    reply.handle().callMethod<void>("writeString", "(Ljava/lang/String;)V", QAndroidJniObject::fromString(payload).object<jstring>());
}
