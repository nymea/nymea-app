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

#ifndef TIMEDESCRIPTOR_H
#define TIMEDESCRIPTOR_H

#include <QObject>

#include <QAbstractListModel>

#include "timeeventitems.h"
#include "calendaritems.h"

class TimeDescriptor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(TimeEventItems* timeEventItems READ timeEventItems CONSTANT)
    Q_PROPERTY(CalendarItems* calendarItems READ calendarItems CONSTANT)
public:
    explicit TimeDescriptor(QObject *parent = nullptr);

    TimeEventItems* timeEventItems() const;
    CalendarItems* calendarItems() const;

    bool operator==(TimeDescriptor* other) const;
signals:

public slots:

private:
    TimeEventItems* m_timeEventItems = nullptr;
    CalendarItems* m_calendarItems = nullptr;
};

#endif // TIMEDESCRIPTOR_H
