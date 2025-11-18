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

#ifndef PARAM_H
#define PARAM_H

#include <QObject>
#include <QUuid>
#include <QVariant>

class Param : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid paramTypeId READ paramTypeId WRITE setParamTypeId NOTIFY paramTypeIdChanged)
    Q_PROPERTY(QVariant value READ value WRITE setValue NOTIFY valueChanged)

public:
    Param(const QUuid &paramTypeId = QString(), const QVariant &value = QVariant(), QObject *parent = nullptr);
    Param(QObject *parent);

    QUuid paramTypeId() const;
    void setParamTypeId(const QUuid &paramTypeId);

    QVariant value() const;
    void setValue(const QVariant &value);

signals:
    void paramTypeIdChanged();
    void valueChanged();

protected:
    QUuid m_paramTypeId;
    QVariant m_value;
};

#endif // PARAM_H
