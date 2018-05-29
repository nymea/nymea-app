#ifndef BLUETOOTHINTERFACE_H
#define BLUETOOTHINTERFACE_H

#include <QObject>
#include <QBluetoothSocket>

#include "nymeainterface.h"
#include "discovery/bluetoothdiscovery.h"

class BluetoothInterface : public NymeaInterface
{
    Q_OBJECT
    Q_PROPERTY(BluetoothDiscovery *discovery READ discovery CONSTANT)

public:
    explicit BluetoothInterface(QObject *parent = 0);

    void sendData(const QByteArray &data) override;
    void sendRequest(const QVariantMap &request) override;

    BluetoothDiscovery *discovery();

private:
    QBluetoothSocket *m_socket;
    QBluetoothServiceInfo m_service;

    BluetoothDiscovery *m_discovery;

signals:

public slots:
    Q_INVOKABLE void enable() override;
    Q_INVOKABLE void disable() override;

private slots:
    void onServiceFound(const QBluetoothServiceInfo &service);
    void onConnected();
    void onDisconnected();

    void onDataReady();

};

#endif // BLUETOOTHINTERFACE_H
