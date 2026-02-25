// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
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
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef LIBNYMEA_APP_EVDASH_H
#define LIBNYMEA_APP_EVDASH_H

#include "evdashmanager.h"
#include "evdashusers.h"

#include <qqml.h>

namespace Nymea {

namespace EvDash {

void registerQmlTypes() {
    qmlRegisterType<EvDashManager>("Nymea.EvDash", 1, 0, "EvDashManager");
    qmlRegisterUncreatableType<EvDashUsers>("Nymea.EvDash", 1, 0, "EvDashUsers", "Get if from the EvDash Manager");
}

}

}

#endif // LIBNYMEA_APP_EVDASH_H
