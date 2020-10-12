#include "nfchelper.h"
#include "types/deviceclass.h"
#include "types/statetype.h"
#include "types/ruleaction.h"
#include "types/ruleactionparams.h"
#include "types/ruleactionparam.h"

#include <QNearFieldManager>
#include <QNdefMessage>
#include <QDebug>
#include <QNdefNfcUriRecord>
#include <QUrl>
#include <QUrlQuery>

NfcHelper::NfcHelper(QObject *parent):
    QObject(parent),
    m_manager(new QNearFieldManager(this)),
    m_actions(new RuleActions(this))
{

    connect(m_manager, &QNearFieldManager::targetDetected, this, &NfcHelper::targetDetected);
    connect(m_manager, &QNearFieldManager::targetLost, this, &NfcHelper::targetLost);

    connect(m_actions, &RuleActions::countChanged, this, &NfcHelper::updateContent);

    m_manager->startTargetDetection();

}

NfcHelper::~NfcHelper()
{
    m_manager->stopTargetDetection();
}

Engine *NfcHelper::engine() const
{
    return m_engine;
}

void NfcHelper::setEngine(Engine *engine)
{
    if (m_engine != engine) {
        m_engine = engine;
        emit engineChanged();
        updateContent();
    }
}

Device *NfcHelper::thing() const
{
    return m_thing;
}

void NfcHelper::setThing(Device *thing)
{
    if (m_thing != thing) {
        m_thing = thing;
        emit thingChanged();
        updateContent();
    }
}

RuleActions *NfcHelper::actions() const
{
    return m_actions;
}

int NfcHelper::messageSize() const
{
    return m_currentMessage.toByteArray().size();
    int ret = 0;
    for (int i = 0; i < m_currentMessage.size(); i++) {
        ret += m_currentMessage.at(i).payload().size();
    }
    return ret;
}

NfcHelper::TagStatus NfcHelper::status() const
{
    return m_status;
}

void NfcHelper::updateContent()
{
    qDebug() << "Updating" << m_engine << m_thing;

    // Creating an URI type record with this format:
    // nymea://<nymeaId>
    // ? t=<thingId>
    // & a[0]=<actionTypeName>
    // & a[1]=<actionTypeName>#<paramName1>:<paramValue>
    // & a[2]=<actionTypeName>#<paramName1>:<paramValue>+<paramName2>:<paramValue>
    // & ...

    // NOTE: We're using actionType and paramType *name* instead of the ID because NFC tags are
    // small and normally names are shorter than ids so we save some space.

    // NOTE: param values are percentage encoded to prevent messing with the parsing if they
    // contain + or :

    QUrl url;
    url.setScheme("nymea");
    if (!m_engine || !m_thing) {
        return;
    }
    url.setHost(m_engine->jsonRpcClient()->currentHost()->uuid().toString().remove(QRegExp("[{}]")));

    QUrlQuery query;

    query.addQueryItem("t", m_thing->id().toString().remove(QRegExp("[{}]")));

    for (int i = 0; i < m_actions->rowCount(); i++) {
        RuleAction *action = m_actions->get(i);
        QStringList params;
        ActionType *at = m_thing->thingClass()->actionTypes()->getActionType(action->actionTypeId());
        if (!at) {
            qWarning() << "ActionType not found in thing" << action->actionTypeId();
            continue;
        }

        for (int j = 0; j < action->ruleActionParams()->rowCount(); j++) {
            RuleActionParam *param = action->ruleActionParams()->get(j);
            ParamType *pt = at->paramTypes()->getParamType(param->paramTypeId());
            if (!pt) {
                qWarning() << "ParamType not found in thing";
                continue;
            }
            params.append(pt->name() + ":" + param->value().toByteArray().toPercentEncoding());
        }
        QString actionString = at->name();
        if (params.length() > 0) {
            actionString += "#" + params.join("+");
        }
        query.addQueryItem(QString("a[%1]").arg(i), actionString);
    }
    url.setQuery(query);
    qDebug() << "writing message" << url;

    QNdefNfcUriRecord record;
    record.setUri(url);
    QNdefMessage message;
    message.append(record);

    m_currentMessage = message;
    emit messageSizeChanged();

}

void NfcHelper::targetDetected(QNearFieldTarget *target)
{
    QDateTime startTime = QDateTime::currentDateTime();
    qDebug() << "target detected";
    connect(target, &QNearFieldTarget::error, this, [=](QNearFieldTarget::Error error, const QNearFieldTarget::RequestId &id){
        qDebug() << "Tag error:" << error;
        m_status = TagStatusFailed;
        emit statusChanged();
    });
    connect(target, &QNearFieldTarget::ndefMessagesWritten, this, [=](){
        qDebug() << "Tag written in" << startTime.msecsTo(QDateTime::currentDateTime());
        m_status = TagStatusWritten;
        emit statusChanged();
    });

    QNearFieldTarget::RequestId m_request = target->writeNdefMessages(QList<QNdefMessage>() << m_currentMessage);
    if (!m_request.isValid()) {
        qDebug() << "Error writing tag";
        m_status = TagStatusFailed;
        emit statusChanged();
    }

    m_status = TagStatusWriting;
    emit statusChanged();
}

void NfcHelper::targetLost(QNearFieldTarget *target)
{
    qDebug() << "Target lost" << target;
    m_status = TagStatusWaiting;
    emit statusChanged();
}

