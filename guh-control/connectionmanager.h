#ifndef CONNECTIONMANAGER_H
#define CONNECTIONMANAGER_H

#include <QObject>
#include <QStateMachine>

#include "guhinterface.h"
#include "websocketinterface.h"
#include "bluetoothinterface.h"
#include "cloudconnection/cloudconnection.h"
#include "discovery/upnpdiscovery.h"

class ConnectionManager : public QObject
{
    Q_OBJECT
    Q_ENUMS(ConnectionType)
    Q_PROPERTY(UpnpDiscovery *upnpDiscovery READ upnpDiscovery CONSTANT)
    Q_PROPERTY(GuhInterface *interface READ interface NOTIFY interfaceChanged)
    Q_PROPERTY(WebsocketInterface *websocketInterface READ websocketInterface CONSTANT)
    Q_PROPERTY(BluetoothInterface *bluetoothInterface READ bluetoothInterface CONSTANT)
    Q_PROPERTY(QString currentInterfaceName READ currentInterfaceName WRITE setCurrentInterfaceName NOTIFY currentInterfaceNameChanged)
    Q_PROPERTY(QString currentStatusMessage READ currentStatusMessage WRITE setCurrentStatusMessage NOTIFY currentStatusMessageChanged)

public:
    enum ConnectionType {
        ConnectionTypeAuto,
        ConnectionTypeWebSocket,
        ConnectionTypeCloud,
        ConnectionTypeBluetooth
    };

    explicit ConnectionManager(QObject *parent = 0);

    GuhInterface *interface();
    UpnpDiscovery *upnpDiscovery();

    WebsocketInterface *websocketInterface();
    BluetoothInterface *bluetoothInterface();

    QString currentInterfaceName() const;
    QString currentStatusMessage() const;

private:
    UpnpDiscovery *m_discovery;
    GuhInterface *m_interface;
    WebsocketInterface *m_websocketInterface;
    BluetoothInterface *m_bluetoothInterface;

    QString m_currentInterfaceName;
    QString m_currentStatusMessage;

    void setInterface(GuhInterface *interface);
    void setCurrentInterfaceName(const QString &name);
    void setCurrentStatusMessage(const QString &message);

private slots:
    void onConnectedChanged();

    // State slots
    void onConnectingState();
    void onUpnpDiscoveringState();

signals:
    void connectedChanged();

    void dataReady(const QVariantMap &data);

    void connected();
    void disconnected();

    void interfaceChanged();
    void websocketInterfaceChanged();
    void currentInterfaceNameChanged();
    void currentStatusMessageChanged();

public slots:
    void start(const ConnectionType &connectionType = ConnectionTypeAuto);
    void stop();

};

#endif // CONNECTIONMANAGER_H
