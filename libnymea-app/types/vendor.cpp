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

#include "vendor.h"

Vendor::Vendor(const QUuid &id, const QString &name, QObject *parent) :
    QObject(parent),
    m_id(id),
    m_name(name)
{
}

QUuid Vendor::id() const
{
    return m_id;
}

void Vendor::setId(const QUuid &id)
{
    m_id = id;
}

QString Vendor::name() const
{
    return m_name;
}

void Vendor::setName(const QString &name)
{
    m_name = name;
}

QString Vendor::displayName() const
{
    return m_displayName;
}
void Vendor::setDisplayName(const QString &displayName)
{
    m_displayName = displayName;
}
