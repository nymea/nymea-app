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

#ifndef PLATFORMHELPERUBPORTS_H
#define PLATFORMHELPERUBPORTS_H

#include <QObject>

#include "platformhelper.h"

class UriHandlerObject: public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.freedesktop.Application")

 public:
    UriHandlerObject(PlatformHelper* platformHelper);

 public Q_SLOTS:
    void Open(const QStringList& uris, const QHash<QString, QVariant>& platformData);

 private:
    PlatformHelper* m_platformHelper = nullptr;
};


class PlatformHelperUBPorts : public PlatformHelper
{
    Q_OBJECT
public:
    explicit PlatformHelperUBPorts(QObject *parent = nullptr);

    QString platform() const override;
    QString deviceSerial() const override;

signals:

private:
    void setupUriHandler();

    UriHandlerObject m_uriHandlerObject;

};

#endif // PLATFORMHELPERUBPORTS_H
