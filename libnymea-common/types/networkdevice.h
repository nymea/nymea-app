#ifndef NETWORKDEVICE_H
#define NETWORKDEVICE_H

#include <QObject>

class WirelessAccessPoint;
class WirelessAccessPoints;

class NetworkDevice : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString macAddress READ macAddress CONSTANT)
    Q_PROPERTY(QString interface READ interface CONSTANT)
    Q_PROPERTY(QString bitRate READ bitRate NOTIFY bitRateChanged)
    Q_PROPERTY(NetworkDeviceState state READ state NOTIFY stateChanged)

public:
    enum NetworkDeviceState {
        NetworkDeviceStateUnknown = 0,
        NetworkDeviceStateUnmanaged = 10,
        NetworkDeviceStateUnavailable = 20,
        NetworkDeviceStateDisconnected = 30,
        NetworkDeviceStatePrepare = 40,
        NetworkDeviceStateConfig = 50,
        NetworkDeviceStateNeedAuth = 60,
        NetworkDeviceStateIpConfig = 70,
        NetworkDeviceStateIpCheck = 80,
        NetworkDeviceStateSecondaries = 90,
        NetworkDeviceStateActivated = 100,
        NetworkDeviceStateDeactivating = 110,
        NetworkDeviceStateFailed = 120
    };
    Q_ENUM(NetworkDeviceState)

    explicit NetworkDevice(const QString &macAddress, const QString &interface, QObject *parent = nullptr);
    virtual ~NetworkDevice() = default;

    QString macAddress() const;
    QString interface() const;

    QString bitRate() const;
    void setBitRate(const QString &bitRate);

    NetworkDeviceState state() const;
    void setState(NetworkDeviceState state);

signals:
    void bitRateChanged();
    void stateChanged();

private:
    QString m_macAddress;
    QString m_interface;
    QString m_bitRate;
    NetworkDeviceState m_state;
};

class WiredNetworkDevice: public NetworkDevice {
    Q_OBJECT
    Q_PROPERTY(bool pluggedIn READ pluggedIn NOTIFY pluggedInChanged)

public:
    explicit WiredNetworkDevice(const QString &macAddress, const QString &interface, QObject *parent = nullptr);

    bool pluggedIn() const;
    void setPluggedIn(bool pluggedIn);

signals:
    void pluggedInChanged();

private:
    bool m_pluggedIn = false;
};

class WirelessNetworkDevice: public NetworkDevice
{
    Q_OBJECT
    Q_PROPERTY(WirelessAccessPoints* accessPoints READ accessPoints CONSTANT)
    Q_PROPERTY(WirelessAccessPoint* currentAccessPoint READ currentAccessPoint CONSTANT)

public:
    explicit WirelessNetworkDevice(const QString &macAddress, const QString &interface, QObject *parent = nullptr);

    WirelessAccessPoints* accessPoints() const;
    WirelessAccessPoint* currentAccessPoint() const;

private:
    WirelessAccessPoints *m_accessPoints = nullptr;
    WirelessAccessPoint *m_currentAccessPoint = nullptr;
};
#endif // NETWORKDEVICE_H
