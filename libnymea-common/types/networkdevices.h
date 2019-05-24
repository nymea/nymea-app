#ifndef NETWORKDEVICES_H
#define NETWORKDEVICES_H

#include <QAbstractListModel>

class NetworkDevice;
class WiredNetworkDevice;
class WirelessNetworkDevice;

class NetworkDevices: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleMacAddress,
        RoleInterface,
        RoleBitRate,
        RoleState,
    };
    Q_ENUM(Roles)

    explicit NetworkDevices(QObject *parent = nullptr);
    virtual ~NetworkDevices() override = default;

    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    virtual QHash<int, QByteArray> roleNames() const override;

    virtual void addNetworkDevice(NetworkDevice *networkDevice);
    void removeNetworkDevice(const QString &interface);

    Q_INVOKABLE virtual NetworkDevice* get(int index) const;
    Q_INVOKABLE virtual NetworkDevice* getNetworkDevice(const QString &interface);

    void clear();

signals:
    void countChanged();

protected:
    QList<NetworkDevice*> m_list;
};

class WiredNetworkDevices: public NetworkDevices
{
    Q_OBJECT
public:
    enum Roles {
        RolePluggedIn = 1000
    };

    explicit WiredNetworkDevices(QObject *parent = nullptr);
    QVariant data(const QModelIndex &index, int role) const override;

    void addNetworkDevice(NetworkDevice *device) override;

    QHash<int, QByteArray> roleNames() const override;
};

class WirelessNetworkDevices: public NetworkDevices
{
    Q_OBJECT
public:
    explicit WirelessNetworkDevices(QObject *parent = nullptr);

    Q_INVOKABLE WirelessNetworkDevice* getWirelessNetworkDevice(const QString &interface);

};

#endif // NETWORKDEVICES_H
