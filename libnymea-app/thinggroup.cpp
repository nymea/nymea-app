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
#include "devicemanager.h"
#include "devicesproxy.h"
#include "types/statetypes.h"
#include "types/actiontype.h"

ThingGroup::ThingGroup(DeviceManager *deviceManager, DeviceClass *deviceClass, DevicesProxy *devices, QObject *parent):
    Device(deviceManager, deviceClass, QUuid::createUuid(), parent),
    m_deviceManager(deviceManager),
    m_devices(devices)
{
    deviceClass->setParent(this);

    States *states = new States(this);
    for (int i = 0; i < deviceClass->stateTypes()->rowCount(); i++) {
        StateType *st = deviceClass->stateTypes()->get(i);
        State *state = new State(id(), st->id(), QVariant(), this);
        qDebug() << "Adding state" << st->name();
        states->addState(state);
    }
    setStates(states);
    syncStates();
    setName(deviceClass->displayName());

    connect(devices, &DevicesProxy::dataChanged, this, [this](const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles){
        syncStates();
    });

    connect(m_deviceManager, &DeviceManager::executeActionReply, this, [this](const QVariantMap &params){
        int returningId = params.value("id").toInt();
        foreach (int id, m_pendingActions.keys()) {
            if (m_pendingActions.value(id).contains(returningId)) {
                m_pendingActions[id].removeAll(returningId);
                if (m_pendingActions[id].isEmpty()) {
                    m_pendingActions.remove(id);
                    emit actionExecutionFinished(id, "DeviceErrorNoError");
                }
                return;
            }
        }
    });

}

int ThingGroup::executeAction(const QString &actionName, const QVariantList &params)
{
    QList<int> pendingIds;

    qDebug() << "Execute action for group:" << this;
    for (int i = 0; i < m_devices->rowCount(); i++) {
        Device *device = m_devices->get(i);
        if (device->setupStatus() != Device::DeviceSetupStatusComplete) {
            continue;
        }
        ActionType *actionType = device->deviceClass()->actionTypes()->findByName(actionName);
        if (!actionType) {
            continue;
        }


        QVariantList finalParams;
        foreach (const QVariant &paramVariant, params) {
            ParamType *paramType = actionType->paramTypes()->findByName(paramVariant.toMap().value("paramName").toString());
            if (paramType) {
                QVariantMap finalParam;
                finalParam.insert("paramTypeId", paramType->id());
                finalParam.insert("value", paramVariant.toMap().value("value"));
                finalParams.append(finalParam);
            }
        }

        qDebug() << "Initial params" << params;
        qDebug() << "Executing" << device->id() << actionType->name() << finalParams;
        int id = m_deviceManager->executeAction(device->id(), actionType->id(), finalParams);
        pendingIds.append(id);
    }
    m_pendingActions.insert(++m_idCounter, pendingIds);
    return m_idCounter;
}

void ThingGroup::syncStates()
{
    for (int i = 0; i < deviceClass()->stateTypes()->rowCount(); i++) {
        StateType *stateType = deviceClass()->stateTypes()->get(i);
        State *state = states()->getState(stateType->id());

        qDebug() << "syncing state" << stateType->name();

        QVariant value;
        int count = 0;
        for (int j = 0; j < m_devices->rowCount(); j++) {
            Device *d = m_devices->get(j);
            // Skip things that don't have the required state
            StateType *ds = d->deviceClass()->stateTypes()->findByName(stateType->name());
            if (!ds) {
                continue;
            }

            // Skip disconnected things
            StateType *connectedStateType = d->deviceClass()->stateTypes()->findByName("connected");
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
            }
        }
        if (count > 0) {
            value = value.toDouble() / count;
        }
        state->setValue(value);
    }
}
