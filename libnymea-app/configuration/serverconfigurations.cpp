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

#include "serverconfigurations.h"
#include "serverconfiguration.h"

ServerConfigurations::ServerConfigurations(QObject *parent) : QAbstractListModel(parent)
{

}

int ServerConfigurations::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant ServerConfigurations::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleId:
        return m_list.at(index.row())->id();
    case RoleAddress:
        return m_list.at(index.row())->address();
    case RolePort:
        return m_list.at(index.row())->port();
    case RoleAuthenticationEnabled:
        return m_list.at(index.row())->authenticationEnabled();
    case RoleSslEnabled:
        return m_list.at(index.row())->sslEnabled();
    }
    return QVariant();
}

QHash<int, QByteArray> ServerConfigurations::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleId, "id");
    roles.insert(RoleAddress, "address");
    roles.insert(RolePort, "port");
    roles.insert(RoleAuthenticationEnabled, "authenticationEnabled");
    roles.insert(RoleSslEnabled, "sslEnabled");
    return roles;
}

void ServerConfigurations::addConfiguration(ServerConfiguration *configuration)
{
    configuration->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(configuration);

    connect(configuration, &ServerConfiguration::addressChanged, this, [this, configuration]() {
        QModelIndex idx = index(m_list.indexOf(configuration), 0);
        emit dataChanged(idx, idx, {RoleAddress});
    });
    connect(configuration, &ServerConfiguration::portChanged, this, [this, configuration]() {
        QModelIndex idx = index(m_list.indexOf(configuration), 0);
        emit dataChanged(idx, idx, {RolePort});
    });
    connect(configuration, &ServerConfiguration::authenticationEnabledChanged, this, [this, configuration]() {
        QModelIndex idx = index(m_list.indexOf(configuration), 0);
        emit dataChanged(idx, idx, {RoleAuthenticationEnabled});
    });
    connect(configuration, &ServerConfiguration::sslEnabledChanged, this, [this, configuration]() {
        QModelIndex idx = index(m_list.indexOf(configuration), 0);
        emit dataChanged(idx, idx, {RoleSslEnabled});
    });

    endInsertRows();
    emit countChanged();
}

void ServerConfigurations::removeConfiguration(const QString &id)
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->id() == id) {
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            emit countChanged();
            return;
        }
    }
}

void ServerConfigurations::clear()
{
    beginResetModel();
    qDeleteAll(m_list);
    m_list.clear();
    endResetModel();
    emit countChanged();
}

ServerConfiguration *ServerConfigurations::get(int index) const
{
    if (index < 0 || index > m_list.count() - 1) {
        return nullptr;
    }
    return m_list.at(index);
}
