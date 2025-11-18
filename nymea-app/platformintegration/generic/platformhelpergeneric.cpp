// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "platformhelpergeneric.h"

#include "logging.h"


Q_DECLARE_LOGGING_CATEGORY(dcPlatformIntegration)

#include <QProcess>
#ifdef HAVE_WEBVIEW
#include <QtWebView>
#endif

PlatformHelperGeneric::PlatformHelperGeneric(QObject *parent) : PlatformHelper(parent)
{
#ifdef HAVE_WEBVIEW
    QtWebView::initialize();
#endif
    m_screenHelper = new ScreenHelper(this);
}

bool PlatformHelperGeneric::canControlScreen() const
{
    return m_screenHelper->active();
}

int PlatformHelperGeneric::screenTimeout() const
{
    return m_screenHelper->screenTimeout();
}

void PlatformHelperGeneric::setScreenTimeout(int timeout)
{
    if (m_screenHelper->screenTimeout() != timeout) {
        m_screenHelper->setScreenTimeout(timeout);
        emit screenTimeoutChanged();
    }
}

int PlatformHelperGeneric::screenBrightness() const
{
    return m_screenHelper->screenBrightness();
}

void PlatformHelperGeneric::setScreenBrightness(int percent)
{
    if (m_screenHelper->screenBrightness() != percent) {
        m_screenHelper->setScreenBrightness(percent);
        emit screenTimeoutChanged();
    }
}
