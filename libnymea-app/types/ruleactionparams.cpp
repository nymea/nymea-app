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

#include "ruleactionparams.h"

#include "ruleactionparam.h"

RuleActionParams::RuleActionParams(QObject *parent) : QAbstractListModel(parent)
{

}

int RuleActionParams::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant RuleActionParams::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleParamTypeId:
        return m_list.at(index.row())->paramTypeId();
    case RoleValue:
        return m_list.at(index.row())->value();
    case RoleEventTypeId:
        return m_list.at(index.row())->eventTypeId();
    case RoleEventParamTypeId:
        return m_list.at(index.row())->eventParamTypeId();
    }
    return QVariant();
}

QHash<int, QByteArray> RuleActionParams::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleParamTypeId, "paramTypeId");
    roles.insert(RoleValue, "value");
    roles.insert(RoleEventTypeId, "eventTypeId");
    roles.insert(RoleEventParamTypeId, "eventParamTypeId");
    return roles;
}

void RuleActionParams::addRuleActionParam(RuleActionParam *ruleActionParam)
{
    ruleActionParam->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(ruleActionParam);
    endInsertRows();
    emit countChanged();
}

void RuleActionParams::setRuleActionParam(const QUuid &paramTypeId, const QVariant &value)
{
    foreach (RuleActionParam *rap, m_list) {
        if (rap->paramTypeId() == paramTypeId) {
            rap->setValue(value);
            return;
        }
    }

    // Still here? Need to add it
    RuleActionParam *rap = new RuleActionParam(this);
    rap->setParamTypeId(paramTypeId);
    rap->setValue(value);
    addRuleActionParam(rap);
}

void RuleActionParams::setRuleActionParamByName(const QString &paramName, const QVariant &value)
{
    foreach (RuleActionParam *rap, m_list) {
        if (rap->paramName() == paramName) {
            rap->setValue(value);
            return;
        }
    }

    // Still here? Need to add it
    RuleActionParam *rap = new RuleActionParam(this);
    rap->setParamName(paramName);
    rap->setValue(value);
    addRuleActionParam(rap);
}

void RuleActionParams::setRuleActionParamEvent(const QString &paramTypeId, const QString &eventTypeId, const QString &eventParamTypeId)
{
    foreach (RuleActionParam *rap, m_list) {
        if (rap->paramTypeId() == paramTypeId) {
            rap->setEventTypeId(eventTypeId);
            rap->setEventParamTypeId(eventParamTypeId);
            return;
        }
    }
    RuleActionParam *rap = new RuleActionParam(this);
    rap->setParamTypeId(paramTypeId);
    rap->setEventTypeId(eventTypeId);
    rap->setEventParamTypeId(eventParamTypeId);
    addRuleActionParam(rap);
}

void RuleActionParams::setRuleActionParamEventByName(const QString &paramName, const QString &eventTypeId, const QString &eventParamTypeId)
{
    foreach (RuleActionParam *rap, m_list) {
        if (rap->paramName() == paramName) {
            rap->setEventTypeId(eventTypeId);
            rap->setEventParamTypeId(eventParamTypeId);
            return;
        }
    }
    RuleActionParam *rap = new RuleActionParam(this);
    rap->setParamName(paramName);
    rap->setEventTypeId(eventTypeId);
    rap->setEventParamTypeId(eventParamTypeId);
    addRuleActionParam(rap);
}

void RuleActionParams::setRuleActionParamState(const QString &paramTypeId, const QString &stateThingId, const QString &stateTypeId)
{
    foreach (RuleActionParam *rap, m_list) {
        if (rap->paramTypeId() == paramTypeId) {
            rap->setStateThingId(stateThingId);
            rap->setStateTypeId(stateTypeId);
            return;
        }
    }
    RuleActionParam *rap = new RuleActionParam(this);
    rap->setParamTypeId(paramTypeId);
    rap->setStateThingId(stateThingId);
    rap->setStateTypeId(stateTypeId);
    addRuleActionParam(rap);
}

void RuleActionParams::setRuleActionParamStateByName(const QString &paramName, const QString &stateThingId, const QString &stateTypeId)
{
    foreach (RuleActionParam *rap, m_list) {
        if (rap->paramName() == paramName) {
            rap->setStateThingId(stateThingId);
            rap->setStateTypeId(stateTypeId);
            return;
        }
    }
    RuleActionParam *rap = new RuleActionParam(this);
    rap->setParamName(paramName);
    rap->setStateThingId(stateThingId);
    rap->setStateTypeId(stateTypeId);
    addRuleActionParam(rap);
}

RuleActionParam *RuleActionParams::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

bool RuleActionParams::hasRuleActionParam(const QString &paramTypeId) const
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->paramTypeId() == paramTypeId) {
            return true;
        }
    }
    return false;
}

void RuleActionParams::clear()
{
    beginResetModel();
    qDeleteAll(m_list);
    m_list.clear();
    endResetModel();
    emit countChanged();
}

bool RuleActionParams::operator==(RuleActionParams *other) const
{
    if (rowCount() != other->rowCount()) {
        return false;
    }
    for (int i = 0; i < rowCount(); i++) {
        if (!get(i)->operator==(other->get(i))) {
            return false;
        }
    }
    return true;
}
