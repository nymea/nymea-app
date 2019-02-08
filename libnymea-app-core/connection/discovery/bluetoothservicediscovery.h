#ifndef BLUETOOTHSERVICEDISCOVERY_H
#define BLUETOOTHSERVICEDISCOVERY_H

#include <QObject>
#include <QBluetoothUuid>
#include <QBluetoothLocalDevice>
#include <QBluetoothServiceDiscoveryAgent>

class NymeaHosts;

class BluetoothServiceDiscovery : public QObject
{
    Q_OBJECT
public:
    explicit BluetoothServiceDiscovery(NymeaHosts *nymeaHosts, QObject *parent = nullptr);

    bool discovering() const;
    bool available() const;

    Q_INVOKABLE void discover();
    Q_INVOKABLE void stopDiscovery();

private:
    NymeaHosts *m_nymeaHosts = nullptr;
    QBluetoothLocalDevice *m_localDevice = nullptr;
    QBluetoothServiceDiscoveryAgent *m_serviceDiscovery = nullptr;
    QBluetoothUuid m_nymeaServiceUuid;

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
