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

#include "thinggroup.h"
#include "thingmanager.h"
#include "thingsproxy.h"
#include "types/statetypes.h"
#include "types/actiontype.h"

ThingGroup::ThingGroup(ThingManager *thingManager, ThingClass *thingClass, ThingsProxy *things, QObject *parent):
    Thing(thingManager, thingClass, QUuid::createUuid(), parent),
    m_things(things)
{
    thingClass->setParent(this);

    States *states = new States(this);
    for (int i = 0; i < thingClass->stateTypes()->rowCount(); i++) {
        StateType *st = thingClass->stateTypes()->get(i);
        State *state = new State(id(), st->id(), QVariant(), this);
        qDebug() << "Adding state" << st->name() << st->minValue() << st->maxValue();
        states->addState(state);
    }
    setStates(states);
    syncStates();
    setName(thingClass->displayName());

    connect(things, &ThingsProxy::dataChanged, this, [this](const QModelIndex &/*topLeft*/, const QModelIndex &/*bottomRight*/, const QVector<int> &/*roles*/){
        syncStates();
    });

    connect(m_thingManager, &ThingManager::executeActionReply, this, [this](int commandId, Thing::ThingError error, const QString &displayMessage){
        // This should maybe check the params and create a sensible group result instead of just forwarding the result of the last reply
        qDebug() << "action reply:" << commandId;
        foreach (int id, m_pendingGroupActions.keys()) {
            if (m_pendingGroupActions.value(id).contains(commandId)) {
                m_pendingGroupActions[id].removeAll(commandId);
                if (m_pendingGroupActions[id].isEmpty()) {
                    m_pendingGroupActions.remove(id);
                    emit executeActionReply(id, error, displayMessage);
                }
                return;
            }
        }
    });

}

int ThingGroup::executeAction(const QString &actionName, const QVariantList &params)
{
    QList<int> pendingIds;

    ActionType *groupActionType = m_thingClass->actionTypes()->findByName(actionName);
    if (!groupActionType) {
        qWarning() << "Group has no action" << actionName;
        return -1;
    }

    qDebug() << "Execute action for group:" << this;
    for (int i = 0; i < m_things->rowCount(); i++) {
        Thing *thing = m_things->get(i);
        if (thing->setupStatus() != Thing::ThingSetupStatusComplete) {
            continue;
        }
        ActionType *actionType = thing->thingClass()->actionTypes()->findByName(actionName);
        if (!actionType) {
            qWarning() << "Cannot send action to thing" << thing->name() << "because according action can't be found";
            continue;
        }


        QVariantList finalParams;
        foreach (const QVariant &paramVariant, params) {
            QString paramName = paramVariant.toMap().value("paramName").toString();
            ParamType *groupParamType = groupActionType->paramTypes()->findByName(paramName);
            if (!groupParamType) {
                qWarning() << "Not adding param" << paramName << "to action" << actionName << "because group action param can't be found";
                continue;
            }
            ParamType *paramType = actionType->paramTypes()->findByName(paramName);
            if (!paramType) {
                qWarning() << "Not adding param" << paramName << "to action" << actionName << "because according action params can't be found";
                continue;
            }

            QVariantMap finalParam;
            finalParam.insert("paramTypeId", paramType->id());
            finalParam.insert("value", mapValue(paramVariant.toMap().value("value"), groupParamType, paramType));
            finalParams.append(finalParam);
        }

        qDebug() << "Initial params" << params;
        qDebug() << "Executing" << thing->id() << actionType->name() << finalParams;
        int id = m_thingManager->executeAction(thing->id(), actionType->id(), finalParams);
        pendingIds.append(id);
    }
    m_pendingGroupActions.insert(++m_idCounter, pendingIds);
    return m_idCounter;
}

void ThingGroup::syncStates()
{
    for (int i = 0; i < thingClass()->stateTypes()->rowCount(); i++) {
        StateType *stateType = thingClass()->stateTypes()->get(i);
        State *state = states()->getState(stateType->id());

        qDebug() << "syncing state" << stateType->name() << stateType->type();

        QVariant value;
        int count = 0;
        for (int j = 0; j < m_things->rowCount(); j++) {
            Thing *d = m_things->get(j);
            // Skip things that don't have the required state
            StateType *ds = d->thingClass()->stateTypes()->findByName(stateType->name());
            if (!ds) {
                continue;
            }

            // Skip disconnected things
            StateType *connectedStateType = d->thingClass()->stateTypes()->findByName("connected");
            if (connectedStateType) {
                if (!d->stateValue(connectedStateType->id()).toBool()) {
                    continue;
                }
            }

            if (stateType->type().toLower() == "bool") {
                if (d->stateValue(ds->id()).toBool()) {
                    value = true;
                    break;
                }
            } else if (stateType->type().toLower() == "int") {
                value = value.toInt() + d->stateValue(ds->id()).toInt();
                count++;
            } else if (stateType->type().toLower() == "qcolor") {
                value = d->stateValue(ds->id());
                break;
            }
        }
        if (count > 0) {
            value = value.toDouble() / count;
        }
        state->setValue(value);
    }
}

QVariant ThingGroup::mapValue(const QVariant &value, ParamType *fromParamType, ParamType *toParamType) const
{
    qDebug() << "Mapping:" << value << fromParamType->minValue() << fromParamType->maxValue() << toParamType->minValue() << toParamType->maxValue();

    if (!fromParamType->minValue().isValid()
            || !fromParamType->maxValue().isValid()
            || !toParamType->minValue().isValid()
            || !toParamType->maxValue().isValid()) {
        return value;
    }
    double fromMin = fromParamType->minValue().toDouble();
    double fromMax = fromParamType->maxValue().toDouble();
    double toMin = toParamType->minValue().toDouble();
    double toMax = toParamType->maxValue().toDouble();
    double fromValue = value.toDouble();
    double fromPercent = (fromValue - fromMin) / (fromMax - fromMin);
    double toValue = toMin + (toMax - toMin) * fromPercent;
    return toValue;
}
