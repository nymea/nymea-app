#include "bluetoothservicediscovery.h"

#include "discoverymodel.h"
#include "discoverydevice.h"

#include <QTimer>

BluetoothServiceDiscovery::BluetoothServiceDiscovery(DiscoveryModel *discoveryModel, QObject *parent) :
    QObject(parent),
    m_discoveryModel(discoveryModel)
{
    m_nymeaServiceUuid = QBluetoothUuid(QUuid("997936b5-d2cd-4c57-b41b-c6048320cd2b"));

    m_localDevice = new QBluetoothLocalDevice(this);
    connect(m_localDevice, &QBluetoothLocalDevice::hostModeStateChanged, this, &BluetoothServiceDiscovery::onHostModeChanged);

    m_serviceDiscovery = new QBluetoothServiceDiscoveryAgent(m_localDevice->address());
    connect(m_serviceDiscovery, &QBluetoothServiceDiscoveryAgent::serviceDiscovered, this, &BluetoothServiceDiscovery::onServiceDiscovered);
    connect(m_serviceDiscovery, &QBluetoothServiceDiscoveryAgent::finished, this, &BluetoothServiceDiscovery::onServiceDiscoveryFinished);
}

bool BluetoothServiceDiscovery::discovering() const
{
    return m_discovering;
}

bool BluetoothServiceDiscovery::available() const
{
    if (!m_localDevice)
        return false;

    return m_localDevice->isValid() && !m_localDevice->hostMode() != QBluetoothLocalDevice::HostPoweredOff;
}

void BluetoothServiceDiscovery::discover()
{
    m_enabed = true;
    if (!m_localDevice->isValid() || m_localDevice->hostMode() == QBluetoothLocalDevice::HostPoweredOff) {
        qWarning() << "BluetoothServiceDiscovery: Not restart discovery, the bluetooth device is not available";
        return;
    }

    m_serviceDiscovery->setUuidFilter(m_nymeaServiceUuid);

    if (m_discovering)
        return;

    qDebug() << "BluetoothServiceDiscovery: Start scanning for service" << m_nymeaServiceUuid.toString();
    setDiscovering(true);
    m_serviceDiscovery->setUuidFilter(m_nymeaServiceUuid);

    // Delay restarting as Bluez might not be ready just yet
    QTimer::singleShot(500, this, [this]() {
        m_serviceDiscovery->start(QBluetoothServiceDiscoveryAgent::FullDiscovery);
    });
}

void BluetoothServiceDiscovery::stopDiscovery()
{
    m_enabed = false;
    setDiscovering(false);
    m_serviceDiscovery->stop();
}

void BluetoothServiceDiscovery::setDiscovering(const bool &discovering)
{
    if (m_discovering == discovering)
        return;

    m_discovering = discovering;
    emit discoveringChanged(m_discovering);
}

void BluetoothServiceDiscovery::onHostModeChanged(const QBluetoothLocalDevice::HostMode &mode)
{
    qDebug() << "BluetoothServiceDiscovery: Host mode changed" << mode;

    if (mode != QBluetoothLocalDevice::HostPoweredOff && m_enabed) {
        qDebug() << "Bluetooth available again, continue discovery";
        discover();
    }

    if (mode == QBluetoothLocalDevice::HostPoweredOff) {
        qDebug() << "BluetoothServiceDiscovery: Bluetooth adapter disabled. Stop discovering";
        m_serviceDiscovery->stop();
    }
}

void BluetoothServiceDiscovery::onServiceDiscovered(const QBluetoothServiceInfo &serviceInfo)
{
    qDebug() << "BluetoothServiceDiscovery: Discovered service on" << serviceInfo.device().name() << serviceInfo.device().address().toString();
    qDebug() << "\tDevive name:" << serviceInfo.device().name();
    qDebug() << "\tService name:" << serviceInfo.serviceName();
    qDebug() << "\tDescription:" << serviceInfo.attribute(QBluetoothServiceInfo::ServiceDescription).toString();
    qDebug() << "\tProvider:" << serviceInfo.attribute(QBluetoothServiceInfo::ServiceProvider).toString();
    qDebug() << "\tDocumentation:" << serviceInfo.attribute(QBluetoothServiceInfo::DocumentationUrl).toString();
    qDebug() << "\tL2CAP protocol service multiplexer:" << serviceInfo.protocolServiceMultiplexer();
    qDebug() << "\tRFCOMM server channel:" << serviceInfo.serverChannel();

    if (serviceInfo.serviceClassUuids().isEmpty())
        return;

    if (serviceInfo.serviceClassUuids().first() == QBluetoothUuid(QUuid("997936b5-d2cd-4c57-b41b-c6048320cd2b"))) {
        qDebug() << "BluetoothServiceDiscovery: Found nymea rfcom service!";

//        DiscoveryDevice* device = m_discoveryModel->find(serviceInfo.device().address());
//        if (!device) {
//            device = new DiscoveryDevice(DiscoveryDevice::DeviceTypeBluetooth, this);
//            qDebug() << "BluetoothServiceDiscovery: Adding new bluetooth host to model";
//            device->setName(QString("%1 (%2)").arg(serviceInfo.serviceName()).arg(serviceInfo.device().name()));
////            device->setBluetoothAddress(serviceInfo.device().address());
//            PortConfig pc;

//            m_discoveryModel->addDevice(device);
//        }
    }
}

void BluetoothServiceDiscovery::onServiceDiscoveryFinished()
{
    qDebug() << "BluetoothServiceDiscovery: Service discovery finished.";
    setDiscovering(false);

    foreach (const QBluetoothServiceInfo &serviceInfo, m_serviceDiscovery->discoveredServices()) {
        onServiceDiscovered(serviceInfo);
    }

    // If discover was called, but never stopDiscover, continue discovery
    if (m_enabed) {
        if (!m_localDevice->isValid() || m_localDevice->hostMode() == QBluetoothLocalDevice::HostPoweredOff) {
            qWarning() << "BluetoothServiceDiscovery: Not restarting discovery, the bluetooth adapter is not available.";
            return;
        }

        qDebug() << "BluetoothServiceDiscovery: Restart service discovery";
        discover();
    }
}
