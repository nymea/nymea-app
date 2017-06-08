/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of guh-control.                                      *
 *                                                                         *
 *  guh-control is free software: you can redistribute it and/or modify    *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  guh-control is distributed in the hope that it will be useful,         *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with guh-control. If not, see <http://www.gnu.org/licenses/>.    *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "devicemanager.h"
#include "engine.h"

DeviceManager::DeviceManager(QObject *parent) :
    QObject(parent),
    m_vendors(new Vendors(this)),
    m_vendorsProxy(new VendorsProxy(this)),
    m_plugins(new Plugins(this)),
    m_pluginsProxy(new PluginsProxy(this)),
    m_devices(new Devices(this)),
    m_devicesProxy(new DevicesProxy(this)),
    m_deviceClasses(new DeviceClasses(this)),
    m_deviceClassesProxy(new DeviceClassesProxy(this))
{
    m_vendorsProxy->setVendors(m_vendors);
    m_pluginsProxy->setPlugins(m_plugins);
    m_devicesProxy->setDevices(m_devices);
    m_deviceClassesProxy->setDeviceClasses(m_deviceClasses);
}

Vendors *DeviceManager::vendors() const
{
    return m_vendors;
}

VendorsProxy *DeviceManager::vendorsProxy() const
{
    return m_vendorsProxy;
}

Plugins *DeviceManager::plugins() const
{
    return m_plugins;
}

PluginsProxy *DeviceManager::pluginsProxy() const
{
    return m_pluginsProxy;
}

Devices *DeviceManager::devices() const
{
    return m_devices;
}

DevicesProxy *DeviceManager::devicesProxy() const
{
    return m_devicesProxy;
}

DeviceClasses *DeviceManager::deviceClasses() const
{
    return m_deviceClasses;
}

DeviceClassesProxy *DeviceManager::deviceClassesProxy() const
{
    return m_deviceClassesProxy;
}


