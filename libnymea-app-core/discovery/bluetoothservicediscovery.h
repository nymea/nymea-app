#ifndef BLUETOOTHSERVICEDISCOVERY_H
#define BLUETOOTHSERVICEDISCOVERY_H

#include <QObject>
#include <QBluetoothLocalDevice>
#include <QBluetoothServiceDiscoveryAgent>

class DiscoveryModel;

class BluetoothServiceDiscovery : public QObject
{
    Q_OBJECT
public:
    explicit BluetoothServiceDiscovery(DiscoveryModel *discoveryModel, QObject *parent = nullptr);

    bool discovering() const;
    bool available() const;

    Q_INVOKABLE void discover(const QBluetoothUuid &uuid);
    Q_INVOKABLE void stopDiscovery();

private:
    DiscoveryModel *m_discoveryModel = nullptr;
    QBluetoothLocalDevice *m_localDevice = nullptr;
    QBluetoothDeviceDiscoveryAgent *m_deviceDiscovery = nullptr;
    QBluetoothServiceDiscoveryAgent *m_serviceDiscovery = nullptr;

    bool m_enabed = false;
    bool m_discovering = false;
    bool m_available = false;

    void setDiscovering(const bool &discovering);

signals:
    void discoveringChanged(bool discovering);

private slots:
    void onHostModeChanged(const QBluetoothLocalDevice::HostMode &mode);

    void onServiceDiscovered(const QBluetoothServiceInfo &serviceInfo);
    void onServiceDiscoveryFinished();

};

#endif // BLUETOOTHSERVICEDISCOVERY_H
