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

#include "mqttpolicies.h"
#include "mqttpolicy.h"

MqttPolicies::MqttPolicies(QObject *parent) : QAbstractListModel(parent)
{

}

int MqttPolicies::rowCount(const QModelIndex &index) const
{
    Q_UNUSED(index)
    return m_list.count();
}

QVariant MqttPolicies::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleClientId:
        return m_list.at(index.row())->clientId();
    case RoleUsername:
        return m_list.at(index.row())->username();
    case RolePassword:
        return m_list.at(index.row())->password();
    case RoleAllowedPublishTopicFilters:
        return m_list.at(index.row())->allowedPublishTopicFilters();
    case RoleAllowedSubscribeTopicFilters:
        return m_list.at(index.row())->allowedSubscribeTopicFilters();
    }
    return QVariant();
}

QHash<int, QByteArray> MqttPolicies::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleClientId, "clientId");
    roles.insert(RoleUsername, "username");
    roles.insert(RolePassword, "password");
    roles.insert(RoleAllowedPublishTopicFilters, "allowedPublishTopicFilters");
    roles.insert(RoleAllowedSubscribeTopicFilters, "allowedSubscribeTopicFilters");
    return roles;
}

void MqttPolicies::addPolicy(MqttPolicy *policy)
{
    policy->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(policy);

    connect(policy, &MqttPolicy::clientIdChanged, this, [this, policy]() {
        QModelIndex index = this->index(m_list.indexOf(policy));
        emit dataChanged(index, index, {RoleClientId});
    });
    connect(policy, &MqttPolicy::usernameChanged, this, [this, policy]() {
        QModelIndex index = this->index(m_list.indexOf(policy));
        emit dataChanged(index, index, {RoleUsername});
    });
    connect(policy, &MqttPolicy::passwordChanged, this, [this, policy]() {
        QModelIndex index = this->index(m_list.indexOf(policy));
        emit dataChanged(index, index, {RolePassword});
    });
    connect(policy, &MqttPolicy::allowedPublishTopicFiltersChanged, this, [this, policy]() {
        QModelIndex index = this->index(m_list.indexOf(policy));
        emit dataChanged(index, index, {RoleAllowedPublishTopicFilters});
    });
    connect(policy, &MqttPolicy::allowedSubscribeTopicFiltersChanged, this, [this, policy]() {
        QModelIndex index = this->index(m_list.indexOf(policy));
        emit dataChanged(index, index, {RoleAllowedSubscribeTopicFilters});
    });

    endInsertRows();
    emit countChanged();
}

void MqttPolicies::removePolicy(MqttPolicy *policy)
{
    int idx = m_list.indexOf(policy);
    if (idx < 0) {
        return;
    }
    beginRemoveRows(QModelIndex(), idx, idx);
    m_list.takeAt(idx)->deleteLater();
    endRemoveRows();
}

MqttPolicy *MqttPolicies::getPolicy(const QString &clientId) const
{
    foreach (MqttPolicy* policy, m_list) {
        if (policy->clientId() == clientId) {
            return policy;
        }
    }
    return nullptr;
}

MqttPolicy *MqttPolicies::get(int index) const
{
    if (index < 0 || index >= m_list.count()){
        return nullptr;
    }
    return m_list.at(index);
}

void MqttPolicies::clear()
{
    beginResetModel();
    qDeleteAll(m_list);
    m_list.clear();
    endResetModel();
}
