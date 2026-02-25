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

#ifndef TIMEEVENTITEMTEMPLATE_H
#define TIMEEVENTITEMTEMPLATE_H

#include <QObject>
#include <QDateTime>
#include <QAbstractListModel>

#include "types/repeatingoption.h"
#include "types/timeeventitem.h"

class TimeEventItemTemplate : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QDateTime dateTime READ dateTime CONSTANT)
    Q_PROPERTY(QTime time READ time CONSTANT)
    Q_PROPERTY(RepeatingOption* repeatingOption READ repeatingOption CONSTANT)
    Q_PROPERTY(bool editable READ editable CONSTANT)

public:
    explicit TimeEventItemTemplate(const QDateTime &dateTime, const QTime &time, RepeatingOption *repeatingOption, bool editable, QObject *parent = nullptr);

    QDateTime dateTime() const;
    QTime time() const;
    RepeatingOption* repeatingOption() const;
    bool editable() const;

    Q_INVOKABLE TimeEventItem* createTimeEventItem() const;

private:
    QDateTime m_dateTime;
    QTime m_time;
    RepeatingOption* m_repeatingOption = nullptr;
    bool m_editable = true;
};

class TimeEventItemTemplates: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount CONSTANT)

public:
    TimeEventItemTemplates(QObject *parent = nullptr): QAbstractListModel(parent) {}
    int rowCount(const QModelIndex &parent = QModelIndex()) const override { Q_UNUSED(parent) return static_cast<int>(m_list.count()); }
    QVariant data(const QModelIndex &index, int role) const override { Q_UNUSED(index) Q_UNUSED(role) return QVariant(); }

    Q_INVOKABLE TimeEventItemTemplate* get(int index) const {
        if (index < 0 || index >= m_list.count()) {
            return nullptr;
        }
        return m_list.at(index);
    }

    void addTimeEventItemTemplate(TimeEventItemTemplate *timeEventItemTemplate) {
        timeEventItemTemplate->setParent(this);
        beginInsertRows(QModelIndex(), static_cast<int>(m_list.count()), static_cast<int>(m_list.count()));
        m_list.append(timeEventItemTemplate);
        endInsertRows();
    }
private:
    QList<TimeEventItemTemplate*> m_list;
};

#endif // TIMEEVENTITEMTEMPLATE_H
