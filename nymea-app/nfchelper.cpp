#include "nfchelper.h"
#include "types/deviceclass.h"
#include "types/statetype.h"

#include <QNearFieldManager>
#include <QNdefMessage>
#include <QDebug>
#include <QNdefNfcUriRecord>
#include <QUrl>
#include <QUrlQuery>

NfcHelper::NfcHelper(QObject *parent) : QObject(parent)
{
    m_manager = new QNearFieldManager(this);
    connect(m_manager, &QNearFieldManager::targetDetected, this, &NfcHelper::targetDetected);
    connect(m_manager, &QNearFieldManager::targetLost, this, &NfcHelper::targetLost);
}

bool NfcHelper::busy() const
{
    return m_busy;
}

void NfcHelper::writeThingStates(Engine *engine, Device *thing)
{
    if (m_busy) {
        return;
    }

    QUrl url;
    url.setScheme("nymea");
    url.setHost(engine->jsonRpcClient()->currentHost()->uuid().toString().remove(QRegExp("[{}]")) + "." + thing->id().toString().remove(QRegExp("[{}]")));
    QUrlQuery query;
    for (int i = 0; i < thing->thingClass()->stateTypes()->rowCount(); i++) {
        StateType *stateType = thing->thingClass()->stateTypes()->get(i);
        ActionType *actionType = thing->thingClass()->actionTypes()->getActionType(stateType->id());
        if (!actionType) {
            continue; // Read only state
        }
        QVariant currentValue = thing->states()->getState(stateType->id())->value();
        query.addQueryItem(stateType->id().toString().remove(QRegExp("[{}]")), currentValue.toString());
    }
    url.setQuery(query);
    qDebug() << "writing message" << url;

    QNdefNfcUriRecord record;
    record.setUri(url);
    QNdefMessage message;
    message.append(record);

    m_currentMessage = message;
    m_manager->startTargetDetection();
    m_busy = true;
    emit busyChanged();
}

void NfcHelper::targetDetected(QNearFieldTarget *target)
{
    connect(target, &QNearFieldTarget::ndefMessagesWritten, this, &NfcHelper::ndefMessageWritten);
    connect(target, &QNearFieldTarget::error, this, &NfcHelper::targetError);


    QNearFieldTarget::RequestId m_request = target->writeNdefMessages(QList<QNdefMessage>() << m_currentMessage);
    if (!m_request.isValid()) {
        qDebug() << "Error writing tag";
        //targetError(QNearFieldTarget::NdefWriteError, m_request);
    }
}

void NfcHelper::targetLost(QNearFieldTarget *target)
{
    qDebug() << "Target lost" << target;
}

void NfcHelper::ndefMessageWritten()
{
    qDebug() << "NDEF message written";
    m_manager->stopTargetDetection();
    m_busy = false;
    emit busyChanged();
}

void NfcHelper::targetError()
{
    qDebug() << "Target error";
}
