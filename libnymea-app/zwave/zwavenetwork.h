#ifndef ZWAVENETWORK_H
#define ZWAVENETWORK_H

#include <QObject>
#include <QUuid>
#include <QAbstractListModel>

class ZWaveNode;
class ZWaveNodes;

class ZWaveNetwork : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid networkUuid READ networkUuid CONSTANT)
    Q_PROPERTY(QString serialPort READ serialPort CONSTANT)
    Q_PROPERTY(quint32 homeId READ homeId NOTIFY homeIdChanged)
    Q_PROPERTY(bool isZWavePlus READ isZWavePlus NOTIFY isZWavePlusChanged)
    Q_PROPERTY(bool isPrimaryController READ isPrimaryController NOTIFY isPrimaryControllerChanged)
    Q_PROPERTY(bool isStaticUpdateController READ isStaticUpdateController NOTIFY isStaticUpdateControllerChanged)
    Q_PROPERTY(bool isBridgeController READ isBridgeController NOTIFY isBridgeControllerChanged)
    Q_PROPERTY(bool waitingForNodeAddition READ waitingForNodeAddition NOTIFY waitingForNodeAdditionChanged)
    Q_PROPERTY(bool waitingForNodeRemoval READ waitingForNodeRemoval NOTIFY waitingForNodeRemovalChanged)
    Q_PROPERTY(ZWaveNetworkState networkState READ networkState NOTIFY networkStateChanged)
    Q_PROPERTY(ZWaveNodes* nodes READ nodes CONSTANT)

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

    Q_INVOKABLE ZWaveNetwork* get(int index) const;
    Q_INVOKABLE ZWaveNetwork* getNetwork(const QUuid &networkUuid);

signals:
    void countChanged();

private:
    QList<ZWaveNetwork*> m_list;
};

#endif // ZWAVENETWORK_H
