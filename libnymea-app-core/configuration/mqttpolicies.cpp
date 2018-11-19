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
