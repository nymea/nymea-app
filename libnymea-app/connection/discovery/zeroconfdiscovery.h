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

#ifndef ZEROCONFDISCOVERY_H
#define ZEROCONFDISCOVERY_H

#ifdef WITH_ZEROCONF
#include "qzeroconf.h"
#endif

#include "../nymeahosts.h"

#include <QObject>

class ZeroconfDiscovery : public QObject
{
    Q_OBJECT

public:
    explicit ZeroconfDiscovery(NymeaHosts *nymeaHosts, QObject *parent = nullptr);
    ~ZeroconfDiscovery();

    bool available() const;
    bool discovering() const;

private:
    NymeaHosts *m_nymeaHosts;

#ifdef WITH_ZEROCONF
    QZeroConf *m_zeroconfJsonRPC = nullptr;
    QZeroConf *m_zeroconfWebSocket = nullptr;

private slots:
    void serviceEntryAdded(const QZeroConfService &entry);
    void serviceEntryRemoved(const QZeroConfService &entry);
#endif
};

#endif // ZEROCONFDISCOVERY_H
