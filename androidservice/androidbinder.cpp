#include "androidbinder.h"
#include "engine.h"
#include "types/device.h"

#include <QDebug>
#include <QAndroidParcel>
#include <QAndroidJniObject>
#include <QJsonDocument>
#include <QtAndroid>

AndroidBinder::AndroidBinder(Engine * engine):
    m_engine(engine)
{
    QAndroidParcel parcel;
    parcel.writeData("foobar");
    transact(10, parcel);
}

bool AndroidBinder::onTransact(int code, const QAndroidParcel &data, const QAndroidParcel &reply, QAndroidBinder::CallType flags)
{
    qDebug() << "onTransact: code " << code << ", flags " << int(flags);

    switch (code) {
    case 0: { // Status request
        bool isReady = m_engine->jsonRpcClient()->connected() && !m_engine->thingManager()->fetchingData();
        reply.handle().callMethod<void>("writeBoolean", "(Z)V", isReady);
    } break;
    case 1: {// Things request
        QVariantList thingsList;
        for (int i = 0; i < m_engine->thingManager()->things()->rowCount(); i++) {
            Device *thing = m_engine->thingManager()->things()->get(i);
            QVariantMap thingMap;
            thingMap.insert("id", thing->id().toString());
            thingMap.insert("name", thing->name());
            thingMap.insert("className", thing->thingClass()->displayName());
            thingMap.insert("interfaces", thing->thingClass()->interfaces());
            QVariantList states;
            for (int j = 0; j < thing->states()->rowCount(); j++) {
                State *state = thing->states()->get(j);
                QVariantMap stateMap;
                stateMap.insert("stateTypeId", state->stateTypeId().toString());
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
                actionMap.insert("actionTypeId", actionType->id().toString());
                actionMap.insert("name", actionType->name());
                actionMap.insert("displayName", actionType->displayName());
                actions.append(actionMap);
            }
            thingMap.insert("actions", actions);
            thingsList.append(thingMap);
        }
        QJsonDocument jsonDoc = QJsonDocument::fromVariant(thingsList);
        reply.handle().callMethod<void>("writeString", "(Ljava/lang/String;)V",  QAndroidJniObject::fromString(jsonDoc.toJson()).object<jstring>());
    } break;
    case 2: {// ExecuteAction
//        QString thingId = data.handle().callMethod<QAndroidJniObject>("readString", "").toString();
//        jstring atId = data.handle().callMethod<jstring>("readString", "");
//        QString actionTypeId = QAndroidJniObject::fromLocalRef(atId).toString();
//        jstring p = data.handle().callMethod<jstring>("readString", "");
//        QString param = QAndroidJniObject::fromLocalRef(p).toString();
        qDebug() << "ExecuteAction";
        QString thingId = data.readData();
        QString actionTypeId = data.readData();
        QString param = data.readData();
        qDebug() << "**** executeAction:" << thingId << actionTypeId << param;

        // FIXME: Only works with state generated actions!
        QVariantMap paramMap;
        paramMap.insert("paramTypeId", actionTypeId);
        paramMap.insert("value", param);
        m_engine->thingManager()->executeAction(thingId, actionTypeId, {paramMap});

    } break;
//    default:
//        QAndroidBinder binder = data.readBinder();

//        qDebug() << TAG << ": onTransact() received non-name data" << data.readVariant();
//        reply.writeVariant(QVariant("Cannot process this!"));

//        // send back message
//        QAndroidParcel sendData, replyData;
//        sendData.writeVariant(QVariant("Send me only names!"));
//        binder.transact(0, sendData, &replyData);
//        qDebug() << TAG << ": onTransact() received " << replyData.readData();

//        break;
    }
    return true;
}
