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

#ifndef TIMEEVENTITEM_H
#define TIMEEVENTITEM_H

#include <QObject>
#include <QDateTime>
#include <QTime>

class RepeatingOption;

class TimeEventItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QDateTime dateTime READ dateTime WRITE setDateTime NOTIFY dateTimeChanged)
    Q_PROPERTY(QTime time READ time WRITE setTime NOTIFY timeChanged)
    Q_PROPERTY(RepeatingOption* repeatingOption READ repeatingOption CONSTANT)

public:
    explicit TimeEventItem(QObject *parent = nullptr);

    QDateTime dateTime() const;
    void setDateTime(const QDateTime &dateTime);

    QTime time() const;
    void setTime(const QTime &time);

    RepeatingOption* repeatingOption() const;

    TimeEventItem* clone() const;
    bool operator==(TimeEventItem *other) const;

signals:
    void dateTimeChanged();
    void timeChanged();

private:
    QDateTime m_dateTime;
    QTime m_time;
    RepeatingOption *m_repeatingOption = nullptr;

};

#endif // TIMEEVENTITEM_H
