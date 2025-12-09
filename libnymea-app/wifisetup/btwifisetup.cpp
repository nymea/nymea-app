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

#include "btwifisetup.h"
#include "bluetoothdeviceinfo.h"
#include "types/wirelessaccesspoints.h"
#include "types/wirelessaccesspoint.h"

#include <QJsonDocument>

#include "logging.h"
NYMEA_LOGGING_CATEGORY(dcBtWiFiSetup, "BtWifi Setup")

static QBluetoothUuid wifiServiceUuid =                 QBluetoothUuid(QUuid("e081fec0-f757-4449-b9c9-bfa83133f7fc"));
static QBluetoothUuid wifiCommanderCharacteristicUuid = QBluetoothUuid(QUuid("e081fec1-f757-4449-b9c9-bfa83133f7fc"));
static QBluetoothUuid wifiResponseCharacteristicUuid =  QBluetoothUuid(QUuid("e081fec2-f757-4449-b9c9-bfa83133f7fc"));
static QBluetoothUuid wifiStatusCharacteristicUuid =    QBluetoothUuid(QUuid("e081fec3-f757-4449-b9c9-bfa83133f7fc"));
static QBluetoothUuid wifiModeCharacteristicUuid =      QBluetoothUuid(QUuid("e081fec4-f757-4449-b9c9-bfa83133f7fc"));
static QBluetoothUuid wifiServiceVersionCharacteristicUuid = QBluetoothUuid(QUuid("e081fec5-f757-4449-b9c9-bfa83133f7fc"));

static QBluetoothUuid networkServiceUuid =                  QBluetoothUuid(QUuid("ef6d6610-b8af-49e0-9eca-ab343513641c"));
static QBluetoothUuid networkStatusCharacteristicUuid =     QBluetoothUuid(QUuid("ef6d6611-b8af-49e0-9eca-ab343513641c"));
static QBluetoothUuid networkCommanderCharacteristicUuid =  QBluetoothUuid(QUuid("ef6d6612-b8af-49e0-9eca-ab343513641c"));
static QBluetoothUuid networkResponseCharacteristicUuid =   QBluetoothUuid(QUuid("ef6d6613-b8af-49e0-9eca-ab343513641c"));
static QBluetoothUuid networkingEnabledCharacteristicUuid = QBluetoothUuid(QUuid("ef6d6614-b8af-49e0-9eca-ab343513641c"));
static QBluetoothUuid wirelessEnabledCharacteristicUuid =   QBluetoothUuid(QUuid("ef6d6615-b8af-49e0-9eca-ab343513641c"));

static QBluetoothUuid systemServiceUuid =                 QBluetoothUuid(QUuid("e081fed0-f757-4449-b9c9-bfa83133f7fc"));
static QBluetoothUuid systemCommanderCharacteristicUuid = QBluetoothUuid(QUuid("e081fed1-f757-4449-b9c9-bfa83133f7fc"));
static QBluetoothUuid systemResponseCharacteristicUuid =  QBluetoothUuid(QUuid("e081fed2-f757-4449-b9c9-bfa83133f7fc"));

BtWiFiSetup::BtWiFiSetup(QObject *parent) : QObject(parent)
{
    m_accessPoints = new WirelessAccessPoints(this);
    qRegisterMetaType<BluetoothDeviceInfo*>("const BluetoothDeviceInfo*");

    connect(this, &BtWiFiSetup::bluetoothStatusChanged, this, [this](){
        qCDebug(dcBtWiFiSetup()) << "Bluetooth status changed" << m_bluetoothStatus;
    });
}

BtWiFiSetup::~BtWiFiSetup()
{
    qCDebug(dcBtWiFiSetup()) << "Destroying BtWifiSetup";
}

int BtWiFiSetup::wirelessServiceVersion() const
{
    return m_wirelessServiceVersion;
}

void BtWiFiSetup::connectToDevice(const BluetoothDeviceInfo *device)
{
    qCDebug(dcBtWiFiSetup()) << "Connecting to device" << device->address() << device->name();
    if (m_btController) {
        delete m_btController;
        m_currentConnection = nullptr;
        currentConnectionChanged();
        m_accessPoints->clearModel();
        m_bluetoothStatus = BluetoothStatusDisconnected;
        emit bluetoothStatusChanged(m_bluetoothStatus);
        m_wirelessServiceVersion = 1;
        emit wirelessServiceVersionChanged();
    }

    m_btController = QLowEnergyController::createCentral(device->bluetoothDeviceInfo(), this);
    connect(m_btController, &QLowEnergyController::connected, this, [this, device](){
        qCInfo(dcBtWiFiSetup()) << "Bluetooth connected" << device->address() << device->name();
        m_btController->discoverServices();
        m_bluetoothStatus = BluetoothStatusConnectedToBluetooth;
        emit bluetoothStatusChanged(m_bluetoothStatus);
    }, Qt::QueuedConnection);


    connect(m_btController, &QLowEnergyController::stateChanged, this, [](QLowEnergyController::ControllerState state){
        qCInfo(dcBtWiFiSetup()) << "Bluetooth constroller state changed" << state;
    });

    connect(m_btController, &QLowEnergyController::disconnected, this, [this](){
        qCInfo(dcBtWiFiSetup()) << "Bluetooth disconnected";
        m_bluetoothStatus = BluetoothStatusDisconnected;
        emit bluetoothStatusChanged(m_bluetoothStatus);
        m_btController->deleteLater();
        m_btController = nullptr;
        m_currentConnection = nullptr;
        emit currentConnectionChanged();
        m_accessPoints->clearModel();
    }, Qt::QueuedConnection);

#if QT_VERSION < QT_VERSION_CHECK(6, 2, 0)
    typedef void (QLowEnergyController::*errorsSignal)(QLowEnergyController::Error);
    connect(m_btController, static_cast<errorsSignal>(&QLowEnergyController::error), this, [this](QLowEnergyController::Error error){
#else
    connect(m_btController, &QLowEnergyController::errorOccurred, this, [this](QLowEnergyController::Error error){
#endif
        qCWarning(dcBtWiFiSetup()) << "Bluetooth error:" << error;
        emit this->bluetoothConnectionError();
    }, Qt::QueuedConnection);

    connect(m_btController, &QLowEnergyController::discoveryFinished, this, [this](){
        qCDebug(dcBtWiFiSetup()) << "Bluetooth service discovery finished";
        setupServices();
    });

    m_bluetoothStatus = BluetoothStatusConnectingToBluetooth;
    emit bluetoothStatusChanged(m_bluetoothStatus);
    m_btController->connectToDevice();
}

void BtWiFiSetup::disconnectFromDevice()
{
    if (m_btController) {
        m_btController->disconnectFromDevice();
    }
}

void BtWiFiSetup::connectDeviceToWiFi(const QString &ssid, const QString &password, bool hidden)
{
    if (m_bluetoothStatus < BluetoothStatusConnectedToBluetooth) {
        qCWarning(dcBtWiFiSetup()) << "Cannot connect to wifi in state" << m_bluetoothStatus;
        return;
    }

    QVariantMap request;
    request.insert("c", (int)WirelessServiceCommandConnect);
    QVariantMap parameters;
    parameters.insert("e", ssid);
    parameters.insert("p", password);
    if (hidden) {
        parameters.insert("h", true);
    }
    request.insert("p", parameters);
    streamData(m_wifiService, wifiCommanderCharacteristicUuid, request);
}

void BtWiFiSetup::disconnectDeviceFromWiFi()
{
    if (m_bluetoothStatus != BluetoothStatusConnectedToBluetooth) {
        qCWarning(dcBtWiFiSetup()) << "Cannot disconnect from wifi in state" << m_bluetoothStatus;
    }
    QVariantMap request;
    request.insert("c", (int)WirelessServiceCommandDisconnect);
    streamData(m_wifiService, wifiCommanderCharacteristicUuid, request);
}

void BtWiFiSetup::scanWiFi()
{
    if (m_bluetoothStatus != BluetoothStatusConnectedToBluetooth) {
        qCWarning(dcBtWiFiSetup()) << "Cannot disconnect from wifi in state" << m_bluetoothStatus;
    }
    QVariantMap request;
    request.insert("c", (int)WirelessServiceCommandScan);
    streamData(m_wifiService, wifiCommanderCharacteristicUuid, request);
}

bool BtWiFiSetup::pressPushButton()
{
    if (!m_systemService) {
        qCWarning(dcBtWiFiSetup()) << "System service not available. Cannot perform push button pairing";
        return false;
    }
    QVariantMap request;
    request.insert("c", (int)SystemServiceCommandPushAuthentication);

    streamData(m_systemService, systemCommanderCharacteristicUuid, request);
    return true;
}

BtWiFiSetup::BluetoothStatus BtWiFiSetup::bluetoothStatus() const
{
    return m_bluetoothStatus;
}

QString BtWiFiSetup::modelNumber() const
{
    return m_modelNumber;
}

QString BtWiFiSetup::manufacturer() const
{
    return m_manufacturer;
}

QString BtWiFiSetup::softwareRevision() const
{
    return m_softwareRevision;
}

QString BtWiFiSetup::firmwareRevision() const
{
    return m_firmwareRevision;
}

QString BtWiFiSetup::hardwareRevision() const
{
    return m_hardwareRevision;
}

BtWiFiSetup::NetworkStatus BtWiFiSetup::networkStatus() const
{
    return m_networkStatus;
}

BtWiFiSetup::WirelessStatus BtWiFiSetup::wirelessStatus() const
{
    return m_wirelessStatus;
}

bool BtWiFiSetup::networkingEnabled() const
{
    return m_networkingEnabled;
}

void BtWiFiSetup::setNetworkingEnabled(bool networkingEnabled)
{
    if (m_bluetoothStatus != BluetoothStatusConnectedToBluetooth) {
        qCWarning(dcBtWiFiSetup()) << "Cannot disconnect from wifi in state" << m_bluetoothStatus;
    }
    QLowEnergyCharacteristic characteristic = m_networkService->characteristic(networkCommanderCharacteristicUuid);
    m_networkService->writeCharacteristic(characteristic, networkingEnabled ? QByteArray::fromHex("00") : QByteArray::fromHex("01"));
}

bool BtWiFiSetup::wirelessEnabled() const
{
    return m_wirelessEnabled;
}

void BtWiFiSetup::setWirelessEnabled(bool wirelessEnabled) const
{
    if (m_bluetoothStatus != BluetoothStatusConnectedToBluetooth) {
        qCWarning(dcBtWiFiSetup()) << "Cannot disconnect from wifi in state" << m_bluetoothStatus;
    }
    QLowEnergyCharacteristic characteristic = m_networkService->characteristic(networkCommanderCharacteristicUuid);
    m_networkService->writeCharacteristic(characteristic, wirelessEnabled ? QByteArray::fromHex("02") : QByteArray::fromHex("03"));
}

WirelessAccessPoints *BtWiFiSetup::accessPoints() const
{
    return m_accessPoints;
}

WirelessAccessPoint *BtWiFiSetup::currentConnection() const
{
    return m_currentConnection;
}

void BtWiFiSetup::setupServices()
{
    qCDebug(dcBtWiFiSetup()) << "Setting up Bluetooth services";
    m_deviceInformationService = m_btController->createServiceObject(QBluetoothUuid::ServiceClassUuid::DeviceInformation, m_btController);
    m_networkService = m_btController->createServiceObject(networkServiceUuid, m_btController);
    m_wifiService = m_btController->createServiceObject(wifiServiceUuid, m_btController);
    m_systemService = m_btController->createServiceObject(systemServiceUuid, m_btController);

    if (!m_wifiService || !m_deviceInformationService || !m_networkService) {
        if (m_btController->property("retries").toInt() < 3) {
            qCDebug(dcBtWiFiSetup()) << "Required services not found on remote device. Retrying...";
            m_btController->discoverServices();
            m_btController->setProperty("retries", m_btController->property("retries").toInt() + 1);
        } else {
            qCWarning(dcBtWiFiSetup()) << "Required services not found on remote device. Disconnecting";
            m_btController->disconnectFromDevice();
        }
        return;
    }

    // Device information
    connect(m_deviceInformationService, &QLowEnergyService::stateChanged, this, [this](QLowEnergyService::ServiceState state) {
        if (state != QLowEnergyService::ServiceDiscovered)
            return;
        qCDebug(dcBtWiFiSetup()) << "Device info service discovered";
        m_manufacturer = QString::fromUtf8(m_deviceInformationService->characteristic(QBluetoothUuid::CharacteristicType::ManufacturerNameString).value());
        emit manufacturerChanged();
        m_modelNumber = QString::fromUtf8(m_deviceInformationService->characteristic(QBluetoothUuid::CharacteristicType::ModelNumberString).value());
        emit modelNumberChanged();
        m_softwareRevision = QString::fromUtf8(m_deviceInformationService->characteristic(QBluetoothUuid::CharacteristicType::SoftwareRevisionString).value());
        emit softwareRevisionChanged();
        m_firmwareRevision = QString::fromUtf8(m_deviceInformationService->characteristic(QBluetoothUuid::CharacteristicType::FirmwareRevisionString).value());
        emit firmwareRevisionChanged();
        m_hardwareRevision = QString::fromUtf8(m_deviceInformationService->characteristic(QBluetoothUuid::CharacteristicType::HardwareRevisionString).value());
        emit hardwareRevisionChanged();
    });
    m_deviceInformationService->discoverDetails();


    // network service
    connect(m_networkService, &QLowEnergyService::stateChanged, this, [this](QLowEnergyService::ServiceState state){
        if (state != QLowEnergyService::ServiceDiscovered)
            return;
        qCDebug(dcBtWiFiSetup()) << "Network service discovered";
        QLowEnergyCharacteristic networkCharacteristic = m_networkService->characteristic(networkStatusCharacteristicUuid);
        QLowEnergyCharacteristic networkingEnabledCharacteristic = m_networkService->characteristic(networkingEnabledCharacteristicUuid);
        QLowEnergyCharacteristic wirelessEnabledCharacteristic = m_networkService->characteristic(wirelessEnabledCharacteristicUuid);
        if (!networkCharacteristic.isValid() || !networkingEnabledCharacteristic.isValid() || !wirelessEnabledCharacteristic.isValid()) {
            qCWarning(dcBtWiFiSetup()) << "Required characteristics not found on remote device (NetworkService)";
            m_btController->disconnectFromDevice();
            return;
        }
        // Enable notifications
        m_networkService->writeDescriptor(networkCharacteristic.descriptor(QBluetoothUuid::DescriptorType::ClientCharacteristicConfiguration), QByteArray::fromHex("0100"));
        m_networkService->writeDescriptor(networkingEnabledCharacteristic.descriptor(QBluetoothUuid::DescriptorType::ClientCharacteristicConfiguration), QByteArray::fromHex("0100"));
        m_networkService->writeDescriptor(wirelessEnabledCharacteristic.descriptor(QBluetoothUuid::DescriptorType::ClientCharacteristicConfiguration), QByteArray::fromHex("0100"));

        m_networkStatus = static_cast<NetworkStatus>(networkCharacteristic.value().toHex().toUInt(nullptr, 16));
        emit networkStatusChanged();
        m_networkingEnabled = networkingEnabledCharacteristic.value().toHex().toUInt(nullptr, 16);
        emit networkingEnabledChanged();
        m_wirelessEnabled = wirelessEnabledCharacteristic.value().toHex().toUInt(nullptr, 16);
        emit wirelessEnabledChanged();

    });
    connect(m_networkService, &QLowEnergyService::characteristicChanged, this, &BtWiFiSetup::characteristicChanged);
    m_networkService->discoverDetails();

    // Wifi service
    connect(m_wifiService, &QLowEnergyService::stateChanged, this, [this](QLowEnergyService::ServiceState state){
        if (state != QLowEnergyService::ServiceDiscovered)
            return;

        qCDebug(dcBtWiFiSetup()) << "Wifi service discovered" << m_wifiService->characteristic(wifiServiceVersionCharacteristicUuid).value();

        m_wifiService->readCharacteristic(m_wifiService->characteristic(wifiServiceVersionCharacteristicUuid));

        // Enable notifations
        m_wifiService->writeDescriptor(m_wifiService->characteristic(wifiResponseCharacteristicUuid).descriptor(QBluetoothUuid::DescriptorType::ClientCharacteristicConfiguration), QByteArray::fromHex("0100"));
        m_wifiService->writeDescriptor(m_wifiService->characteristic(wifiStatusCharacteristicUuid).descriptor(QBluetoothUuid::DescriptorType::ClientCharacteristicConfiguration), QByteArray::fromHex("0100"));

        qCDebug(dcBtWiFiSetup()) << "Fetching networks after init";
        loadNetworks();
    });
    connect(m_wifiService, &QLowEnergyService::characteristicRead, this, &BtWiFiSetup::characteristicChanged);
    connect(m_wifiService, &QLowEnergyService::characteristicChanged, this, &BtWiFiSetup::characteristicChanged);
    m_wifiService->discoverDetails();


    // System service (optional)
    if (m_systemService) {
        connect(m_systemService, &QLowEnergyService::stateChanged, this, [this](QLowEnergyService::ServiceState state){
            if (state != QLowEnergyService::ServiceDiscovered)
                return;
            qCDebug(dcBtWiFiSetup()) << "System service discovered";
            m_systemService->writeDescriptor(m_systemService->characteristic(systemResponseCharacteristicUuid).descriptor(QBluetoothUuid::DescriptorType::ClientCharacteristicConfiguration), QByteArray::fromHex("0100"));
        });
        m_systemService->discoverDetails();
    }
}

void BtWiFiSetup::streamData(QLowEnergyService *service, const QUuid &characteristicUuid, const QVariantMap &request)
{
    QLowEnergyCharacteristic characteristic = service->characteristic(characteristicUuid);
    QByteArray data = QJsonDocument::fromVariant(request).toJson(QJsonDocument::Compact) + '\n';

    QByteArray remainingData = data;
    while (!remainingData.isEmpty()) {
        QByteArray package = remainingData.left(20);
        m_wifiService->writeCharacteristic(characteristic, package);
        remainingData = remainingData.remove(0, package.count());
    }
}

void BtWiFiSetup::processWiFiPacket(const QVariantMap &data)
{
    WirelessServiceCommand command = static_cast<WirelessServiceCommand>(data.value("c").toInt());
    WirelessServiceResponse responseCode = (WirelessServiceResponse)data.value("r").toInt();
    if (responseCode != WirelessServiceResponseSuccess) {
        qCWarning(dcBtWiFiSetup()) << "Error in wifi command" << command << ":" << responseCode;
        emit wifiSetupError();
        return;
    }

    qCDebug(dcBtWiFiSetup()) << "command reply:" << command;
    switch (command) {
    case WirelessServiceCommandGetNetworks:

        foreach (const QVariant &data, data.value("p").toList()) {
            bool found = false;
            for (int i = 0; i < m_accessPoints->rowCount(); i++) {
                WirelessAccessPoint *existingAp = m_accessPoints->get(i);
                if (existingAp->macAddress() == data.toMap().value("m").toString()) {
                    found = true;
                }
            }
            if (found) {
                continue;
            }

            WirelessAccessPoint *accessPoint = new WirelessAccessPoint(this);
            accessPoint->setSsid(data.toMap().value("e").toString());
            accessPoint->setMacAddress(data.toMap().value("m").toString());
            accessPoint->setSignalStrength(data.toMap().value("s").toInt());
            accessPoint->setProtected(data.toMap().value("p").toBool());
            accessPoint->setHostAddress("");
            m_accessPoints->addWirelessAccessPoint(accessPoint);

        }
        loadCurrentConnection();
        break;
    case WirelessServiceCommandConnect:
        qCDebug(dcBtWiFiSetup()) << "Connect call succeeded";
        break;
    case WirelessServiceCommandGetCurrentConnection: {
        // Find current network
        QVariantMap currentConnection = data.value("p").toMap();
        if (!currentConnection.value("m").toString().isEmpty() && currentConnection.value("i").toString().isEmpty()) {
            // There's a bug in libnymea-networkmanager that sometimes it emits current connection before it actually obtained the IP address
            qCDebug(dcBtWiFiSetup()) << "Retring to fetch the current connection because IP is not set yet.";
            loadCurrentConnection();
            return;
        }
        m_currentConnection = nullptr;
        foreach (WirelessAccessPoint *accessPoint, m_accessPoints->wirelessAccessPoints()) {
            QString macAddress = currentConnection.value("m").toString();
            if (accessPoint->macAddress() == macAddress) {
                // Set the current network
                m_currentConnection = accessPoint;

                accessPoint->setHostAddress(currentConnection.value("i").toString());
            }
        }
        if (!m_currentConnection && !currentConnection.value("m").toString().isEmpty()) {
            // There's a currentConnection, but we don't know it in our AP list yet. Creating it.
            // (This happens for example when connecting to a hidden wifi)
            WirelessAccessPoint *newAP = new WirelessAccessPoint(this);
            newAP->setSsid(currentConnection.value("e").toString());
            newAP->setMacAddress(currentConnection.value("m").toString());
            newAP->setSignalStrength(currentConnection.value("s").toInt());
            newAP->setProtected(currentConnection.value("p").toBool());
            newAP->setHostAddress(currentConnection.value("i").toString());
            m_accessPoints->addWirelessAccessPoint(newAP);
            m_currentConnection = newAP;
        }
        qCDebug(dcBtWiFiSetup()) << "current connection is:" << m_currentConnection;
        emit currentConnectionChanged();

        if (m_bluetoothStatus != BluetoothStatusLoaded) {
            m_bluetoothStatus = BluetoothStatusLoaded;
            emit bluetoothStatusChanged(m_bluetoothStatus);
        }

        break;
    }
    case WirelessServiceCommandScan:
        if (responseCode == WirelessServiceResponseSuccess) {
            qCDebug(dcBtWiFiSetup()) << "Fetching networks after wifi scan";
            loadNetworks();
        }
        break;
    default:
        qCWarning(dcBtWiFiSetup()) << "Unhandled command reply";
    }
}

void BtWiFiSetup::loadNetworks()
{
    QVariantMap request;
    request.insert("c", (int)WirelessServiceCommandGetNetworks);
    streamData(m_wifiService, wifiCommanderCharacteristicUuid, request);
}

void BtWiFiSetup::loadCurrentConnection()
{
    QVariantMap request;
    request.insert("c", (int)WirelessServiceCommandGetCurrentConnection);
    streamData(m_wifiService, wifiCommanderCharacteristicUuid, request);
}

void BtWiFiSetup::characteristicChanged(const QLowEnergyCharacteristic &characteristic, const QByteArray &value)
{    
    if (characteristic.uuid() == wifiServiceVersionCharacteristicUuid) {
        qCDebug(dcBtWiFiSetup()) << "Wireless service version received:" << value;
        m_wirelessServiceVersion = value.toInt();
        emit wirelessServiceVersionChanged();

    } else  if (characteristic.uuid() == wifiResponseCharacteristicUuid) {

        m_inputBuffers[characteristic.uuid()].append(value);
        if (!m_inputBuffers[characteristic.uuid()].endsWith("\n")) {
            return;
        }
        QByteArray data = m_inputBuffers.take(characteristic.uuid());
        QJsonParseError error;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(data.trimmed(), &error);
        if (error.error != QJsonParseError::NoError) {
            qCWarning(dcBtWiFiSetup()) << "Invalid json data received:" << error.errorString() << data.trimmed() << "from characteristic:" << characteristic.uuid();
            m_btController->disconnectFromDevice();
            return;
        }
        processWiFiPacket(jsonDoc.toVariant().toMap());

    } else if (characteristic.uuid() == wifiStatusCharacteristicUuid) {

        m_wirelessStatus = static_cast<WirelessStatus>(value.toHex().toInt(nullptr, 16));
        qCDebug(dcBtWiFiSetup()) << "Wireless status changed" << m_wirelessStatus;
        emit wirelessStatusChanged();

        if (m_wirelessStatus == WirelessStatusFailed) {
            emit wifiSetupError();
        } else if (m_wirelessStatus == WirelessStatusActivated) {
            loadCurrentConnection();
        }

        // Note: wirelessEnabled characterristic seems broken server-side. Let's check the wifiStatus for it being enabled or not
        if (m_wirelessEnabled != (m_wirelessStatus != WirelessStatusUnavailable)) {
            m_wirelessEnabled = m_wirelessStatus != WirelessStatusUnavailable;
            emit wirelessEnabledChanged();
        }

    } else if (characteristic.uuid() == networkStatusCharacteristicUuid) {
        m_networkStatus = static_cast<NetworkStatus>(value.toHex().toInt(nullptr, 16));
        qCDebug(dcBtWiFiSetup()) << "Network status changed:" << m_networkStatus;
        if (m_networkStatus == NetworkStatusGlobal || m_networkStatus == NetworkStatusLocal || m_networkStatus == NetworkStatusConnectedSite) {
            loadCurrentConnection();
        }

        // Note: networkingEnabled characterristic seems broken server-side. Let's check the networkStatus for it being enabled or not
        if (m_wirelessEnabled != (m_networkStatus != NetworkStatusAsleep)) {
            m_networkingEnabled = m_networkStatus != NetworkStatusAsleep;
            emit wirelessEnabledChanged();
        }

    } else {
        qCWarning(dcBtWiFiSetup()) << "Unhandled packet from characteristic" << characteristic.uuid();
    }
}
