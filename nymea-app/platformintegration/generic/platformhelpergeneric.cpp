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

#include "logging.h"

extern "C" {
#include <ply-boot-client.h>
}

Q_DECLARE_LOGGING_CATEGORY(dcPlatformIntegration)

PlatformHelperGeneric::PlatformHelperGeneric(QObject *parent) : PlatformHelper(parent)
{
    m_piHelper = new ScreenHelper(this);
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

void PlatformHelperGeneric::hideSplashScreen()
{
    ply_event_loop_t *loop = ply_event_loop_new();
    ply_boot_client_t *client = ply_boot_client_new();
    bool status = ply_boot_client_connect(client, [] (void* data, ply_boot_client_t *) -> void {
        PlatformHelperGeneric *thiz = reinterpret_cast<PlatformHelperGeneric*>(data);
//        ply_event_loop_exit(this.loop, 0);
//                                 ply_boot_client_free(client);
        }, this);
    if (!status) {
        qCCritical(dcPlatformIntegration()) << "Cannot deactivate splash screen";
    }
    ply_boot_client_attach_to_event_loop(client, loop);
    ply_boot_client_tell_daemon_to_deactivate(client, nullptr, nullptr, nullptr);
}
