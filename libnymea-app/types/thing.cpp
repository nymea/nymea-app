/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "thing.h"
#include "thingclass.h"
#include "thingmanager.h"

#include <QLoggingCategory>
Q_DECLARE_LOGGING_CATEGORY(dcThingManager)

Thing::Thing(ThingManager *thingManager, ThingClass *thingClass, const QUuid &parentId, QObject *parent) :
    QObject(parent),
    m_thingManager(thingManager),
    m_parentId(parentId),
    m_thingClass(thingClass)
{
    connect(thingManager, &ThingManager::executeActionReply, this, [=](int commandId, Thing::ThingError thingError, const QString &displayMessage){
        if (m_pendingActions.contains(commandId)) {
            m_pendingActions.removeAll(commandId);
            emit executeActionReply(commandId, thingError, displayMessage);
        }
    });
}

QString Thing::name() const
{
    return m_name;
}

void Thing::setName(const QString &name)
{
    m_name = name;
    emit nameChanged();
}

QUuid Thing::id() const
{
    return m_id;
}

void Thing::setId(const QUuid &id)
{
    m_id = id;
}

QUuid Thing::thingClassId() const
{
    return m_thingClass->id();
}

QUuid Thing::parentId() const
{
    return m_parentId;
}

bool Thing::isChild() const
{
    return !m_parentId.isNull();
}

Thing::ThingSetupStatus Thing::setupStatus() const
{
    return m_setupStatus;
}

QString Thing::setupDisplayMessage() const
{
    return m_setupDisplayMessage;
}

void Thing::setSetupStatus(Thing::ThingSetupStatus setupStatus, const QString &displayMessage)
{
    if (m_setupStatus != setupStatus || m_setupDisplayMessage != displayMessage) {
        m_setupStatus = setupStatus;
        m_setupDisplayMessage = displayMessage;
        emit setupStatusChanged();
    }
}

Params *Thing::params() const
{
    return m_params;
}

void Thing::setParams(Params *params)
{
    if (m_params != params) {
        if (m_params) {
            m_params->deleteLater();
        }
        params->setParent(this);
        m_params = params;
        emit paramsChanged();
    }
}

Params *Thing::settings() const
{
    return m_settings;
}

void Thing::setSettings(Params *settings)
{
    if (m_settings != settings) {
        if (m_settings) {
            m_settings->deleteLater();
        }
        settings->setParent(this);
        m_settings = settings;
        emit settingsChanged();
    }
}

States *Thing::states() const
{
    return m_states;
}

void Thing::setStates(States *states)
{
    if (m_states != states) {
        if (m_states) {
            m_states->deleteLater();
        }
        states->setParent(this);
        m_states = states;
        emit statesChanged();
    }
}

State *Thing::state(const QUuid &stateTypeId) const
{
    return m_states->getState(stateTypeId);
}

State *Thing::stateByName(const QString &stateName) const
{
    StateType *st = m_thingClass->stateTypes()->findByName(stateName);
    if (!st) {
        return nullptr;
    }
    return m_states->getState(st->id());
}

Param *Thing::param(const QUuid &paramTypeId) const
{
    return m_params->getParam(paramTypeId);
}

Param *Thing::paramByName(const QString &paramName) const
{
    ParamType *paramType = m_thingClass->paramTypes()->findByName(paramName);
    if (!paramType) {
        return nullptr;
    }
    return m_params->getParam(paramType->id());
}

ThingClass *Thing::thingClass() const
{
    return m_thingClass;
}

bool Thing::hasState(const QUuid &stateTypeId) const
{
    foreach (State *state, states()->states()) {
        if (state->stateTypeId() == stateTypeId) {
            return true;
        }
    }
    return false;
}

QVariant Thing::stateValue(const QUuid &stateTypeId) const
{
    foreach (State *state, states()->states()) {
        if (state->stateTypeId() == stateTypeId) {
            return state->value();
        }
    }
    return QVariant();
}

void Thing::setStateValue(const QUuid &stateTypeId, const QVariant &value)
{
    foreach (State *state, states()->states()) {
        if (state->stateTypeId() == stateTypeId) {
            state->setValue(value);
            return;
        }
    }
}

QList<QUuid> Thing::loggedStateTypeIds() const
{
    return m_loggedStateTypeIds;
}

void Thing::setLoggedStateTypeIds(const QList<QUuid> &loggedStateTypeIds)
{
    if (m_loggedStateTypeIds != loggedStateTypeIds) {
        m_loggedStateTypeIds = loggedStateTypeIds;
        emit loggedStateTypeIdsChanged();
    }
}

QList<QUuid> Thing::loggedEventTypeIds() const
{
    return m_loggedEventTypeIds;
}

void Thing::setLoggedEventTypeIds(const QList<QUuid> &loggedEventTypeIds)
{
    if (m_loggedEventTypeIds != loggedEventTypeIds) {
        m_loggedEventTypeIds = loggedEventTypeIds;
        emit loggedEventTypeIdsChanged();
    }
}

QList<QUuid> Thing::loggedActionTypeIds() const
{
    return m_loggedActionTypeIds;
}

void Thing::setLoggedActionTypeIds(const QList<QUuid> &loggedActionTypeIds)
{
    if (m_loggedActionTypeIds != loggedActionTypeIds) {
        m_loggedActionTypeIds = loggedActionTypeIds;
        emit loggedActionTypeIdsChanged();
    }
}

int Thing::executeAction(const QString &actionName, const QVariantList &params)
{
    ActionType *actionType = m_thingClass->actionTypes()->findByName(actionName);
    if (!actionType) {
        actionType = m_thingClass->actionTypes()->getActionType(QUuid(actionName));
        if (!actionType) {
            qCWarning(dcThingManager) << "No such action" << actionName << "in thing class" << m_thingClass->name();
            return -1;
        }
    }

    QVariantList finalParams;
    foreach (const QVariant &paramVariant, params) {
        QVariantMap param = paramVariant.toMap();
        if (!param.contains("paramTypeId") && param.contains("paramName")) {
            ParamType *paramType = actionType->paramTypes()->findByName(param.take("paramName").toString());
            param.insert("paramTypeId", paramType->id());
        }
        finalParams.append(param);
    }
//    qCritical() << "Executing action" << finalParams;
    int commandId = m_thingManager->executeAction(m_id, actionType->id(), finalParams);
    m_pendingActions.append(commandId);
    return commandId;
}

QDebug operator<<(QDebug &dbg, Thing *thing)
{
    dbg.nospace() << "Thing: " << thing->name() << " (" << thing->id().toString() << ") Class:" << thing->thingClass()->name() << " (" << thing->thingClassId().toString() << ")" << Qt::endl;
    for (int i = 0; i < thing->thingClass()->paramTypes()->rowCount(); i++) {
        ParamType *pt = thing->thingClass()->paramTypes()->get(i);
        Param *p = thing->params()->getParam(pt->id());
        if (p) {
            dbg << "  Param " << i << ": " << pt->id().toString() << ": " << pt->name() << " = " << p->value() << Qt::endl;
        } else {
            dbg << "  Param " << i << ": " << pt->id().toString() << ": " << pt->name() << " = " << "*** Unknown value ***" << Qt::endl;
        }
    }
    for (int i = 0; i < thing->thingClass()->settingsTypes()->rowCount(); i++) {
        ParamType *pt = thing->thingClass()->settingsTypes()->get(i);
        Param *p = thing->settings()->getParam(pt->id());
        if (p) {
            dbg << "  Setting " << i << ": " << pt->id().toString() << ": " << pt->name() << " = " << p->value() << Qt::endl;
        } else {
            dbg << "  Setting " << i << ": " << pt->id().toString() << ": " << pt->name() << " = " << "*** Unknown value ***" << Qt::endl;
        }
    }
    for (int i = 0; i < thing->thingClass()->stateTypes()->rowCount(); i++) {
        StateType *st = thing->thingClass()->stateTypes()->get(i);
        State *s = thing->states()->getState(st->id());
        dbg << "  State " << i << ": " << st->id() << ": " << st->name() << " = " << s->value() << Qt::endl;
    }
    return dbg;
}
