/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "networkmanagercontroller.h"

NetworkManagerController::NetworkManagerController(QObject *parent) : QObject(parent)
{

}

BluetoothDeviceInfo *NetworkManagerController::bluetoothDeviceInfo() const
{
    return m_bluetoothDeviceInfo;
}

void NetworkManagerController::setBluetoothDeviceInfo(BluetoothDeviceInfo *bluetoothDeviceInfo)
{
    if (m_bluetoothDeviceInfo != bluetoothDeviceInfo) {
        m_bluetoothDeviceInfo = bluetoothDeviceInfo;
        emit bluetoothDeviceInfoChanged();
    }
}

WirelessSetupManager *NetworkManagerController::manager()
{
    return m_wirelessSetupManager;
}

void NetworkManagerController::connectDevice()
{
    if (!m_bluetoothDeviceInfo) {
        qWarning() << "Can't connect to device. bluetoothDeviceInfo not set.";
        return;
    }

    if (m_wirelessSetupManager) {
        delete m_wirelessSetupManager;
        m_wirelessSetupManager = nullptr;
        emit managerChanged();
    }

    if (!m_bluetoothDeviceInfo) {
        qDebug() << "Could not connect to device. There is no device info for" << m_bluetoothDeviceInfo->name() << m_bluetoothDeviceInfo->address();
        return;
    }

    m_wirelessSetupManager = new WirelessSetupManager(m_bluetoothDeviceInfo->getBluetoothDeviceInfo(), this);
    emit managerChanged();

    m_wirelessSetupManager->connectDevice();
}
