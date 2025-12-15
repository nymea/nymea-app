// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef ZWAVENETWORK_H
#define ZWAVENETWORK_H

#include <QObject>
#include <QUuid>
#include <QAbstractListModel>

#include "zwavenode.h"

class ZWaveNetwork : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid networkUuid READ networkUuid CONSTANT FINAL)
    Q_PROPERTY(QString serialPort READ serialPort CONSTANT FINAL)
    Q_PROPERTY(quint32 homeId READ homeId NOTIFY homeIdChanged FINAL)
    Q_PROPERTY(bool isZWavePlus READ isZWavePlus NOTIFY isZWavePlusChanged FINAL)
    Q_PROPERTY(bool isPrimaryController READ isPrimaryController NOTIFY isPrimaryControllerChanged FINAL)
    Q_PROPERTY(bool isStaticUpdateController READ isStaticUpdateController NOTIFY isStaticUpdateControllerChanged FINAL)
    Q_PROPERTY(bool isBridgeController READ isBridgeController NOTIFY isBridgeControllerChanged FINAL)
    Q_PROPERTY(bool waitingForNodeAddition READ waitingForNodeAddition NOTIFY waitingForNodeAdditionChanged FINAL)
    Q_PROPERTY(bool waitingForNodeRemoval READ waitingForNodeRemoval NOTIFY waitingForNodeRemovalChanged FINAL)
    Q_PROPERTY(ZWaveNetworkState networkState READ networkState NOTIFY networkStateChanged FINAL)
    Q_PROPERTY(ZWaveNodes* nodes READ nodes CONSTANT FINAL)

public:
    enum ZWaveNetworkState {
        ZWaveNetworkStateOffline,
        ZWaveNetworkStateStarting,
        ZWaveNetworkStateOnline,
        ZWaveNetworkStateError
    };
    Q_ENUM(ZWaveNetworkState)

    explicit ZWaveNetwork(const QUuid &networkUuid, const QString &serialPort, QObject *parent = nullptr);

    QUuid networkUuid() const;
    QString serialPort() const;

    quint32 homeId() const;
    void setHomeId(quint32 homeId);

    bool isZWavePlus() const;
    void setIsZWavePlus(bool isZWavePlus);

    bool isPrimaryController() const;
    void setIsPrimaryController(bool isPrimaryController);

    bool isStaticUpdateController() const;
    void setIsStaticUpdateController(bool isStaticUpdateController);

    bool isBridgeController() const;
    void setIsBridgeController(bool isBridgeController);

    bool waitingForNodeAddition() const;
    void setWaitingForNodeAddition(bool waitingForNodeAddition);

    bool waitingForNodeRemoval() const;
    void setWaitingForNodeRemoval(bool waitingForNodeRemoval);

    ZWaveNetworkState networkState() const;
    void setNetworkState(ZWaveNetworkState networkState);

    ZWaveNodes* nodes() const;

    void addNode(ZWaveNode *node);
    void removeNode(quint8 nodeId);

signals:
    void networkStateChanged();
    void homeIdChanged();
    void isZWavePlusChanged();
    void isPrimaryControllerChanged();
    void isStaticUpdateControllerChanged();
    void isBridgeControllerChanged();
    void waitingForNodeAdditionChanged();
    void waitingForNodeRemovalChanged();

private:
    QUuid m_networkUuid;
    QString m_serialPort;
    quint32 m_homeId = 0;
    bool m_isZWavePlus = false;
    bool m_isPrimaryController = false;
    bool m_isStaticUpdateController = false;
    bool m_isBridgeController = false;
    bool m_waitingForNodeAddition = false;
    bool m_waitingForNodeRemoval = false;
    ZWaveNetworkState m_networkState = ZWaveNetworkStateOffline;

    ZWaveNodes* m_nodes = nullptr;
};


class ZWaveNetworks: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        RoleUuid,
        RoleSerialPort,
        RoleHomeId,
        RoleIsZWavePlus,
        RoleIsPrimaryController,
        RoleIsStaticUpdateController,
        RoleNetworkState
    };
    Q_ENUM(Roles)

    ZWaveNetworks(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void clear();
    void addNetwork(ZWaveNetwork *network);
    void removeNetwork(const QUuid &networkUuid);

    Q_INVOKABLE ZWaveNetwork *get(int index) const;
    Q_INVOKABLE ZWaveNetwork *getNetwork(const QUuid &networkUuid);

signals:
    void countChanged();

private:
    QList<ZWaveNetwork *> m_list;
};

#endif // ZWAVENETWORK_H
