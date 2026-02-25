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

#ifndef TIMEDESCRIPTORTEMPLATE_H
#define TIMEDESCRIPTORTEMPLATE_H

#include <QObject>

#include "calendaritemtemplate.h"
#include "timeeventitemtemplate.h"

class TimeDescriptorTemplate : public QObject
{
    Q_OBJECT
    Q_PROPERTY(CalendarItemTemplates* calendarItemTemplates READ calendarItemTemplates CONSTANT)
    Q_PROPERTY(TimeEventItemTemplates* timeEventItemTemplates READ timeEventItemTemplates CONSTANT)

public:
    explicit TimeDescriptorTemplate(QObject *parent = nullptr);

    CalendarItemTemplates* calendarItemTemplates() const;
    TimeEventItemTemplates* timeEventItemTemplates() const;

private:
    CalendarItemTemplates *m_calendarItemTemplates = nullptr;
    TimeEventItemTemplates *m_timeEventItemTemplates = nullptr;
};

#endif // TIMEDESCRIPTORTEMPLATE_H
