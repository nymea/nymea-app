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

#include "platformhelpergeneric.h"

PlatformHelperGeneric::PlatformHelperGeneric(QObject *parent) : PlatformHelper(parent)
{
    m_piHelper = new ScreenHelper(this);
}

void PlatformHelperGeneric::requestPermissions()
{
    emit permissionsRequestFinished();
}

void PlatformHelperGeneric::hideSplashScreen()
{

}

bool PlatformHelperGeneric::hasPermissions() const
{
    return true;
}

QString PlatformHelperGeneric::machineHostname() const
{
    return QSysInfo::machineHostName();
}

QString PlatformHelperGeneric::device() const
{
    return QSysInfo::prettyProductName();
}

QString PlatformHelperGeneric::deviceSerial() const
{
#if QT_VERSION >= QT_VERSION_CHECK(5, 11, 0)
    return QSysInfo::machineUniqueId();
#else
    return "1234567890";
#endif
}

QString PlatformHelperGeneric::deviceModel() const
{
    return QSysInfo::prettyProductName();
}

QString PlatformHelperGeneric::deviceManufacturer() const
{
    return QSysInfo::productType();
}

bool PlatformHelperGeneric::canControlScreen() const
{
    return m_piHelper->active();
}

int PlatformHelperGeneric::screenTimeout() const
{
    return m_piHelper->screenTimeout();
}

void PlatformHelperGeneric::setScreenTimeout(int timeout)
{
    if (m_piHelper->screenTimeout() != timeout) {
        m_piHelper->setScreenTimeout(timeout);
        emit screenTimeoutChanged();
    }
}

int PlatformHelperGeneric::screenBrightness() const
{
    return m_piHelper->screenBrightness();
}

void PlatformHelperGeneric::setScreenBrightness(int percent)
{
    if (m_piHelper->screenBrightness() != percent) {
        m_piHelper->setScreenBrightness(percent);
        emit screenTimeoutChanged();
    }
}

void PlatformHelperGeneric::vibrate(PlatformHelper::HapticsFeedback feedbyckType)
{
    Q_UNUSED(feedbyckType)
}
